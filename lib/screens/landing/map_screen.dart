import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map_compass/flutter_map_compass.dart';
import 'package:synquerra/providers/user_provider.dart';
import 'package:synquerra/providers/device_provider.dart';
import 'package:synquerra/providers/searched_device_provider.dart';
import 'package:synquerra/screens/landing/device_details_sheet.dart';
import '../../core/services/device_service.dart';
import '../../screens/landing/home/my_profile_drawer.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final MapController _mapController = MapController();
  double _currentZoom = 13;

  List<String> _allImeis = [];
  bool _isLoadingImeis = false;
  bool _hasLoadedImeis = false;
  bool _showHistory = false;
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProv = context.read<UserProvider>();
      userProv.initUser().then((_) {
        if (userProv.user?.imei != null) {
          context.read<DeviceProvider>().refreshMyDevice(userProv.user!.imei);
        }
      });
    });

    _searchFocusNode.addListener(() {
      if (_searchFocusNode.hasFocus && !_hasLoadedImeis) _loadImeis();
    });
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadImeis() async {
    if (_hasLoadedImeis || _isLoadingImeis) return;
    setState(() => _isLoadingImeis = true);
    try {
      final imeis = await DeviceService().getDeviceImeis();
      if (mounted) {
        setState(() {
          _allImeis = imeis;
          _hasLoadedImeis = true;
          _isLoadingImeis = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingImeis = false);
    }
  }

  void _handleSearchSelection(String imei) async {
    if (imei.isEmpty) return;
    FocusScope.of(context).unfocus();
    final currentUser = context.read<UserProvider>().user;

    if (imei == currentUser?.imei) {
      context.read<SearchedDeviceProvider>().clearSearch();
    } else {
      await context.read<SearchedDeviceProvider>().fetchSearchedDevice(imei);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final myProv = context.watch<DeviceProvider>();
    final searchProv = context.watch<SearchedDeviceProvider>();

    final bool showingSearch = searchProv.currentImei != null;
    final activeTelemetry = showingSearch
        ? searchProv.latestTelemetry
        : myProv.latestTelemetry;
    final isLoadingData = showingSearch
        ? searchProv.isLoading
        : myProv.isLoading;

    final LatLng deviceLatLng = activeTelemetry?.latitude != null
        ? LatLng(activeTelemetry!.latitude!, activeTelemetry!.longitude!)
        : const LatLng(32.9090, 74.8016);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (activeTelemetry?.latitude != null && !isLoadingData) {
        _mapController.move(deviceLatLng, _currentZoom);
      }
    });

    return PopScope(
      canPop: !showingSearch,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (showingSearch) {
          context.read<SearchedDeviceProvider>().clearSearch();
        }
      },
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          key: _scaffoldKey,
          endDrawer: const MyProfileDrawer(),
          body: Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: deviceLatLng,
                  initialZoom: _currentZoom,
                  onPositionChanged: (pos, gesture) {
                    if (pos.zoom != _currentZoom) _currentZoom = pos.zoom;
                    if (gesture) FocusScope.of(context).unfocus();
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://api.maptiler.com/maps/openstreetmap/{z}/{x}/{y}.png?key=uOv6PI7AYa13sqD3rQbo',
                    userAgentPackageName: 'com.synquerra.app',
                  ),

                  // --- 1. HISTORY LAYER (Should be below the marker) ---
                  if (_showHistory && activeTelemetry != null)
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: () {
                            // 1. Get the raw list
                            final rawPackets = (showingSearch
                                ? searchProv.allPackets
                                : myProv.allPackets);

                            if (rawPackets.isEmpty) return <LatLng>[];

                            // 2. Identify the "Last 1000" range safely
                            // If list is 5000: start at 4000, end at 5000.
                            // If list is 500: start at 0, end at 500.
                            final int totalCount = rawPackets.length;
                            final int start = totalCount > 100
                                ? totalCount - 100
                                : 0;

                            final recentPackets = rawPackets.sublist(
                              start,
                              totalCount,
                            );

                            // 3. Extract points using alternate step (every 5th)
                            List<LatLng> filteredPoints = [];
                            for (int i = 0; i < recentPackets.length; i += 5) {
                              final p = recentPackets[i];
                              if (p.latitude != null && p.longitude != null) {
                                filteredPoints.add(
                                  LatLng(p.latitude!, p.longitude!),
                                );
                              }
                            }

                            // 4. Critical: Always force the very last (latest) packet into the line
                            // even if it wasn't a multiple of 5, so the line connects to the current marker.
                            if (recentPackets.last.latitude != null) {
                              final lastP = recentPackets.last;
                              final lastLatLng = LatLng(
                                lastP.latitude!,
                                lastP.longitude!,
                              );
                              if (!filteredPoints.contains(lastLatLng)) {
                                filteredPoints.add(lastLatLng);
                              }
                            }

                            return filteredPoints;
                          }(),
                          strokeWidth: 4.0,
                          color: Colors.blue.withOpacity(0.5),
                          strokeCap: StrokeCap.round,
                          strokeJoin: StrokeJoin.round,
                        ),
                      ],
                    ),

                  // --- 2. LIVE MARKER LAYER ---
                  if (activeTelemetry != null)
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: deviceLatLng,
                          width: 80,
                          height: 80,
                          child: const Icon(
                            Icons.boy_rounded,
                            color: Colors.green,
                            size: 50,
                          ),
                        ),
                      ],
                    ),

                  MapCompass(
                    icon: const Icon(
                      Icons.explore_outlined,
                      size: 36,
                      color: Colors.black87,
                    ),
                    alignment: Alignment.topRight,
                    padding: const EdgeInsets.only(top: 110, right: 10),
                  ),
                ],
              ),

              // Search Bar
              Positioned(
                top: MediaQuery.of(context).padding.top + 10,
                left: 10,
                right: 10,
                child: _buildSearchBar(theme.colorScheme),
              ),

              // Zoom Controls
              Positioned(
                top: MediaQuery.of(context).padding.top + 130,
                right: 10,
                child: _buildZoomControls(theme.colorScheme),
              ),

              // Modular Sheet
              DeviceDetailsSheet(
                showingSearch: showingSearch,
                isHistoryVisible: _showHistory,
                onToggleHistory: () {
                  setState(() {
                    _showHistory = !_showHistory;
                  });
                },
              ),

              // Loading Overlay
              if (isLoadingData)
                Container(
                  color: Colors.black.withOpacity(0.4),
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: Colors.white),
                        SizedBox(height: 16),
                        Text(
                          "Updating Tracking Data...",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ... (Keep your existing _buildSearchBar and _buildZoomControls methods)
  Widget _buildSearchBar(ColorScheme colorScheme) {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            const Icon(Icons.search, color: Colors.grey),
            const SizedBox(width: 8),
            Expanded(
              child: Autocomplete<String>(
                key: ValueKey(_hasLoadedImeis),
                optionsBuilder: (textValue) async {
                  if (!_hasLoadedImeis) {
                    _loadImeis();
                    return const Iterable<String>.empty();
                  }
                  if (textValue.text == '') return _allImeis.take(5);
                  return _allImeis
                      .where((imei) => imei.contains(textValue.text))
                      .take(5);
                },
                onSelected: (selection) => _handleSearchSelection(selection),
                fieldViewBuilder: (ctx, ctrl, node, onSub) {
                  return TextField(
                    controller: ctrl,
                    focusNode: node,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (v) => _handleSearchSelection(v),
                    decoration: const InputDecoration(
                      hintText: "Search Device by IMEI",
                      border: InputBorder.none,
                    ),
                  );
                },
              ),
            ),
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildZoomControls(ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          const BoxShadow(
            blurRadius: 4,
            color: Colors.black26,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              setState(() {
                _currentZoom++;
                _mapController.move(_mapController.camera.center, _currentZoom);
              });
            },
            iconSize: 28,
          ),
          const Divider(height: 1, thickness: 1, indent: 5, endIndent: 5),
          IconButton(
            icon: const Icon(Icons.remove),
            onPressed: () {
              setState(() {
                _currentZoom--;
                _mapController.move(_mapController.camera.center, _currentZoom);
              });
            },
            iconSize: 28,
          ),
        ],
      ),
    );
  }
}
// _______________________________________________________________________
// -----------------Working code-----------------

// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:latlong2/latlong.dart';
// import 'package:provider/provider.dart';
// import 'package:flutter_map_compass/flutter_map_compass.dart';
// import 'package:synquerra/providers/user_provider.dart';
// import 'package:synquerra/providers/device_provider.dart';
// import 'package:synquerra/providers/searched_device_provider.dart';
// import 'package:synquerra/screens/landing/home/details/data_telemetry_screen.dart';
// import '../../core/services/device_service.dart';
// import '../../screens/landing/home/my_profile_drawer.dart';

// class MapScreen extends StatefulWidget {
//   const MapScreen({super.key});

//   @override
//   State<MapScreen> createState() => _MapScreenState();
// }

// class _MapScreenState extends State<MapScreen> {
//   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
//   final MapController _mapController = MapController();
//   double _currentZoom = 13;

//   // Search Logic State (Visuals)
//   List<String> _allImeis = [];
//   bool _isLoadingImeis = false;
//   bool _hasLoadedImeis = false;
//   final FocusNode _searchFocusNode = FocusNode();

//   @override
//   void initState() {
//     super.initState();

//     // 1. Structural Init: Load User and then Device Data
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final userProv = context.read<UserProvider>();
//       userProv.initUser().then((_) {
//         if (userProv.user?.imei != null) {
//           context.read<DeviceProvider>().refreshMyDevice(userProv.user!.imei);
//         }
//       });
//     });

//     // 2. Focus System listener for search bar
//     _searchFocusNode.addListener(() {
//       if (_searchFocusNode.hasFocus && !_hasLoadedImeis) _loadImeis();
//     });
//   }

//   @override
//   void dispose() {
//     _searchFocusNode.dispose();
//     super.dispose();
//   }

//   Future<void> _loadImeis() async {
//     if (_hasLoadedImeis || _isLoadingImeis) return;
//     setState(() => _isLoadingImeis = true);
//     try {
//       final imeis = await DeviceService().getDeviceImeis();
//       if (mounted) {
//         setState(() {
//           _allImeis = imeis;
//           _hasLoadedImeis = true;
//           _isLoadingImeis = false;
//         });
//       }
//     } catch (e) {
//       if (mounted) setState(() => _isLoadingImeis = false);
//     }
//   }

//   void _navigateToDetails(String imei) async {
//     if (imei.isEmpty) return;
//     FocusScope.of(context).unfocus(); // Original focus system
//     final currentUser = context.read<UserProvider>().user;

//     if (imei != currentUser?.imei) {
//       await context.read<SearchedDeviceProvider>().fetchSearchedDevice(imei);
//     }

//     if (mounted) {
//       Navigator.push(
//         context,
//         MaterialPageRoute(builder: (_) => DataTelemetryScreen(imei: imei)),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final colorScheme = theme.colorScheme;

//     // Watch Global Providers
//     final user = context.watch<UserProvider>().user;
//     final myProv = context.watch<DeviceProvider>();
//     final searchProv = context.watch<SearchedDeviceProvider>();

//     final bool showingSearch = searchProv.currentImei != null;
//     final activeTelemetry = showingSearch
//         ? searchProv.latestTelemetry
//         : myProv.latestTelemetry;
//     final activeHealth = showingSearch
//         ? searchProv.healthData
//         : myProv.healthData;
//     final isLoadingData = showingSearch
//         ? searchProv.isLoading
//         : myProv.isLoading;

//     // Use hardware coordinates or default Jammu
//     final LatLng deviceLatLng = activeTelemetry?.latitude != null
//         ? LatLng(activeTelemetry!.latitude!, activeTelemetry!.longitude!)
//         : const LatLng(32.9090, 74.8016);

//     // AUTO-PAN CAMERA (Post-Frame to avoid build loops)
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (activeTelemetry?.latitude != null && !isLoadingData) {
//         _mapController.move(deviceLatLng, _currentZoom);
//       }
//     });

//     return GestureDetector(
//       onTap: () => FocusScope.of(context).unfocus(), // Original Focus System
//       child: Scaffold(
//         key: _scaffoldKey,
//         endDrawer: const MyProfileDrawer(),
//         body: Stack(
//           children: [
//             // --- MAP LAYER ---
//             FlutterMap(
//               mapController: _mapController,
//               options: MapOptions(
//                 initialCenter: deviceLatLng,
//                 initialZoom: _currentZoom,
//                 onPositionChanged: (pos, gesture) {
//                   if (pos.zoom != _currentZoom) _currentZoom = pos.zoom;
//                   if (gesture)
//                     FocusScope.of(context).unfocus(); // Unfocus on pan
//                 },
//               ),
//               children: [
//                 TileLayer(
//                   urlTemplate:
//                       'https://api.maptiler.com/maps/openstreetmap/{z}/{x}/{y}.png?key=uOv6PI7AYa13sqD3rQbo',
//                   userAgentPackageName: 'com.synquerra.app',
//                 ),
//                 if (activeTelemetry != null)
//                   MarkerLayer(
//                     markers: [
//                       Marker(
//                         point: deviceLatLng,
//                         width: 80,
//                         height: 80,
//                         child: const Icon(
//                           Icons.location_pin,
//                           color: Colors.red,
//                           size: 40,
//                         ),
//                       ),
//                     ],
//                   ),
//                 MapCompass(
//                   icon: const Icon(
//                     Icons.explore_outlined,
//                     size: 36,
//                     color: Colors.black87,
//                   ),
//                   alignment: Alignment.topRight,
//                   padding: const EdgeInsets.only(top: 110, right: 10),
//                 ),
//               ],
//             ),

//             // --- SEARCH BAR (Visual Style Reinstated) ---
//             Positioned(
//               top: MediaQuery.of(context).padding.top + 10,
//               left: 10,
//               right: 10,
//               child: Material(
//                 elevation: 4,
//                 borderRadius: BorderRadius.circular(30),
//                 child: Container(
//                   decoration: BoxDecoration(
//                     color: colorScheme.surface,
//                     borderRadius: BorderRadius.circular(30),
//                   ),
//                   child: Row(
//                     children: [
//                       const Padding(
//                         padding: EdgeInsets.symmetric(horizontal: 12.0),
//                         child: Icon(Icons.search, color: Colors.grey),
//                       ),
//                       Expanded(
//                         child: Autocomplete<String>(
//                           key: ValueKey(_hasLoadedImeis),
//                           optionsBuilder: (val) async {
//                             if (!_hasLoadedImeis) {
//                               _loadImeis();
//                               return const Iterable<String>.empty();
//                             }
//                             if (val.text == '') return _allImeis.take(5);
//                             return _allImeis
//                                 .where((i) => i.contains(val.text))
//                                 .take(5);
//                           },
//                           onSelected: (selection) =>
//                               _navigateToDetails(selection),
//                           optionsViewBuilder: (context, onSelected, options) {
//                             return Align(
//                               alignment: Alignment.topLeft,
//                               child: Material(
//                                 elevation: 4.0,
//                                 borderRadius: BorderRadius.circular(20),
//                                 child: Container(
//                                   width:
//                                       MediaQuery.of(context).size.width -
//                                       100, // Matching old code look
//                                   constraints: const BoxConstraints(
//                                     maxHeight: 250,
//                                   ),
//                                   child: ListView.builder(
//                                     padding: EdgeInsets.zero,
//                                     shrinkWrap: true,
//                                     itemCount: options.length,
//                                     itemBuilder: (ctx, idx) => ListTile(
//                                       leading: const Icon(
//                                         Icons.history,
//                                         color: Colors.grey,
//                                         size: 20,
//                                       ),
//                                       title: Text(options.elementAt(idx)),
//                                       onTap: () =>
//                                           onSelected(options.elementAt(idx)),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             );
//                           },
//                           fieldViewBuilder: (ctx, ctrl, node, onSub) {
//                             return TextField(
//                               controller: ctrl,
//                               focusNode: node,
//                               textInputAction: TextInputAction.search,
//                               onSubmitted: (v) => _navigateToDetails(v),
//                               decoration: InputDecoration(
//                                 hintText: _isLoadingImeis
//                                     ? "Loading..."
//                                     : "Search Device by IMEI",
//                                 border: InputBorder.none,
//                                 contentPadding: EdgeInsets.zero,
//                               ),
//                             );
//                           },
//                         ),
//                       ),
//                       IconButton(
//                         icon: const Icon(Icons.person_outline),
//                         onPressed: () {},
//                       ),
//                       IconButton(
//                         icon: const Icon(Icons.menu),
//                         onPressed: () =>
//                             _scaffoldKey.currentState?.openEndDrawer(),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),

//             // --- ZOOM CONTROLS ---
//             Positioned(
//               top: MediaQuery.of(context).padding.top + 130,
//               right: 10,
//               child: _buildZoomControls(colorScheme),
//             ),

//             // --- DATA SHEET ---
//             DraggableScrollableSheet(
//               initialChildSize: 0.15,
//               minChildSize: 0.15,
//               maxChildSize: 0.8,
//               builder: (context, scrollController) {
//                 return Container(
//                   decoration: BoxDecoration(
//                     color: colorScheme.surface,
//                     borderRadius: const BorderRadius.vertical(
//                       top: Radius.circular(20),
//                     ),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.3),
//                         blurRadius: 15,
//                         spreadRadius: 5,
//                       ),
//                     ],
//                   ),
//                   child: ListView(
//                     controller: scrollController,
//                     padding: const EdgeInsets.symmetric(vertical: 12.0),
//                     children: [
//                       Center(
//                         child: Container(
//                           width: 40,
//                           height: 5,
//                           decoration: BoxDecoration(
//                             color: Colors.grey[300],
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                         ),
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text(
//                               showingSearch
//                                   ? "Viewing Searched"
//                                   : "Tracking ${user?.firstName ?? 'Leela'}",
//                               style: theme.textTheme.titleLarge?.copyWith(
//                                 fontSize: 24,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             Row(
//                               children: [
//                                 Text(
//                                   "${activeTelemetry?.battery ?? '0'}%",
//                                   style: theme.textTheme.titleSmall?.copyWith(
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                                 const SizedBox(width: 4),
//                                 const Icon(
//                                   Icons.battery_full,
//                                   color: Colors.green,
//                                   size: 24,
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                         child: Text(
//                           "Last Seen: ${activeTelemetry?.timestamp ?? 'Fetching...'}",
//                           style: theme.textTheme.bodyLarge?.copyWith(
//                             color: colorScheme.onSurfaceVariant,
//                             fontSize: 18,
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 12),

//                       buildInfoRow(
//                         context,
//                         icon: Icons.location_history,
//                         label: "GEO Number:",
//                         value: "3",
//                         valueSuffix: " Safe Zone",
//                         valueSuffixColor: Colors.green,
//                         theme: theme,
//                       ),
//                       buildInfoRow(
//                         context,
//                         icon: Icons.score,
//                         label: "GPS Score:",
//                         value: "${activeHealth?.gpsScore.toInt() ?? 0}",
//                         valueSuffix: " / 100",
//                         valueSuffixColor: Colors.blue,
//                         theme: theme,
//                       ),
//                       buildInfoRow(
//                         context,
//                         icon: Icons.speed,
//                         label: "${activeTelemetry?.speed ?? 0.0} Km/hr",
//                         value: "${activeTelemetry?.temperature ?? '32'}°C",
//                         theme: theme,
//                       ),
//                       buildInfoRow(
//                         context,
//                         icon: Icons.signal_cellular_alt,
//                         label: "SIM 1",
//                         value: "Signal Strength: ",
//                         valueSuffix: "${activeTelemetry?.signal ?? 74}%",
//                         valueSuffixColor: Colors.green,
//                         theme: theme,
//                       ),
//                       buildInfoRow(
//                         context,
//                         icon: Icons.sos,
//                         label: "SOS",
//                         value: "Enable",
//                         theme: theme,
//                       ),

//                       const SizedBox(height: 20),
//                       const Divider(indent: 60, endIndent: 60),
//                       Padding(
//                         padding: const EdgeInsets.all(16.0),
//                         child: Text(
//                           "Guardian Contacts:",
//                           style: theme.textTheme.titleMedium?.copyWith(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 18,
//                           ),
//                         ),
//                       ),
//                       buildContactCard(
//                         context,
//                         name: "${user?.firstName} ${user?.lastName}",
//                         phoneNumber: user?.mobile ?? "N/A",
//                         email: user?.email ?? "N/A",
//                         theme: theme,
//                       ),

//                       const Divider(indent: 60, endIndent: 60),
//                       Padding(
//                         padding: const EdgeInsets.all(16.0),
//                         child: Text(
//                           "Device Details",
//                           style: theme.textTheme.titleMedium?.copyWith(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 18,
//                           ),
//                         ),
//                       ),
//                       buildInfoRow(
//                         context,
//                         icon: Icons.devices,
//                         label: "IMEI (Device):",
//                         value: user?.imei ?? "---",
//                         theme: theme,
//                       ),
//                       buildInfoRow(
//                         context,
//                         icon: Icons.memory,
//                         label: "Firmware:",
//                         value: "1dfv3515",
//                         theme: theme,
//                       ),

//                       if (showingSearch)
//                         Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                           child: ElevatedButton(
//                             onPressed: () => context
//                                 .read<SearchedDeviceProvider>()
//                                 .clearSearch(),
//                             child: const Text("Return to My Device"),
//                           ),
//                         ),
//                       const SizedBox(height: 100),
//                     ],
//                   ),
//                 );
//               },
//             ),

//             // --- LOADING SCREEN OVERLAY (NEW Feature) ---
//             if (isLoadingData)
//               Container(
//                 color: Colors.black.withOpacity(0.4),
//                 child: const Center(
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       CircularProgressIndicator(color: Colors.white),
//                       SizedBox(height: 16),
//                       Text(
//                         "Updating Tracking Data...",
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildZoomControls(ColorScheme colorScheme) {
//     return Container(
//       decoration: BoxDecoration(
//         color: colorScheme.surface.withOpacity(0.9),
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             blurRadius: 4,
//             color: Colors.black26,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           IconButton(
//             icon: const Icon(Icons.add),
//             onPressed: () {
//               setState(() {
//                 _currentZoom++;
//                 _mapController.move(_mapController.camera.center, _currentZoom);
//               });
//             },
//             iconSize: 28,
//           ),
//           const Divider(height: 1, thickness: 1, indent: 5, endIndent: 5),
//           IconButton(
//             icon: const Icon(Icons.remove),
//             onPressed: () {
//               setState(() {
//                 _currentZoom--;
//                 _mapController.move(_mapController.camera.center, _currentZoom);
//               });
//             },
//             iconSize: 28,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget buildInfoRow(
//     BuildContext context, {
//     required String label,
//     required String value,
//     IconData? icon,
//     String? valueSuffix,
//     Color? valueSuffixColor,
//     required ThemeData theme,
//     Color? valueColor,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
//       child: Row(
//         children: [
//           if (icon != null)
//             Icon(
//               icon,
//               size: 20,
//               color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
//             ),
//           const SizedBox(width: 10),
//           SizedBox(
//             width: 120,
//             child: Text(
//               label,
//               style: theme.textTheme.bodyLarge?.copyWith(
//                 fontSize: 18,
//                 color: theme.colorScheme.onSurfaceVariant,
//               ),
//             ),
//           ),
//           Expanded(
//             child: Row(
//               children: [
//                 Text(
//                   value,
//                   style: theme.textTheme.bodyLarge?.copyWith(
//                     fontSize: 18,
//                     color: valueColor ?? theme.colorScheme.onSurface,
//                   ),
//                 ),
//                 if (valueSuffix != null)
//                   Text(
//                     valueSuffix,
//                     style: theme.textTheme.bodyLarge?.copyWith(
//                       fontSize: 18,
//                       fontWeight: FontWeight.w600,
//                       color: valueSuffixColor ?? theme.colorScheme.onSurface,
//                     ),
//                   ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget buildContactCard(
//     BuildContext context, {
//     required String name,
//     required String phoneNumber,
//     required String email,
//     required ThemeData theme,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   name,
//                   style: theme.textTheme.titleMedium?.copyWith(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 Text(
//                   phoneNumber,
//                   style: theme.textTheme.bodyLarge?.copyWith(
//                     fontSize: 16,
//                     color: theme.colorScheme.onSurfaceVariant,
//                   ),
//                 ),
//                 Text(
//                   email,
//                   style: theme.textTheme.bodyLarge?.copyWith(
//                     fontSize: 16,
//                     color: theme.colorScheme.onSurfaceVariant,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           IconButton(
//             icon: const Icon(Icons.call, color: Colors.white),
//             style: IconButton.styleFrom(backgroundColor: theme.primaryColor),
//             onPressed: () {},
//           ),
//         ],
//       ),
//     );
//   }
// }
