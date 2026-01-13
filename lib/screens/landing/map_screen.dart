import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map_compass/flutter_map_compass.dart';
import 'package:synquerra/providers/user_provider.dart';
import 'package:synquerra/providers/device_provider.dart';
import 'package:synquerra/providers/searched_device_provider.dart';
import 'package:synquerra/screens/landing/home/details/data_telemetry_screen.dart';
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

  // Search Logic State (Visuals)
  List<String> _allImeis = [];
  bool _isLoadingImeis = false;
  bool _hasLoadedImeis = false;
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    // 1. Structural Init: Load User and then Device Data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProv = context.read<UserProvider>();
      userProv.initUser().then((_) {
        if (userProv.user?.imei != null) {
          context.read<DeviceProvider>().refreshMyDevice(userProv.user!.imei);
        }
      });
    });

    // 2. Focus System listener for search bar
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

  void _navigateToDetails(String imei) async {
    if (imei.isEmpty) return;
    FocusScope.of(context).unfocus(); // Original focus system
    final currentUser = context.read<UserProvider>().user;

    if (imei != currentUser?.imei) {
      await context.read<SearchedDeviceProvider>().fetchSearchedDevice(imei);
    }

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => DataTelemetryScreen(imei: imei)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Watch Global Providers
    final user = context.watch<UserProvider>().user;
    final myProv = context.watch<DeviceProvider>();
    final searchProv = context.watch<SearchedDeviceProvider>();

    final bool showingSearch = searchProv.currentImei != null;
    final activeTelemetry = showingSearch
        ? searchProv.latestTelemetry
        : myProv.latestTelemetry;
    final activeHealth = showingSearch
        ? searchProv.healthData
        : myProv.healthData;
    final isLoadingData = showingSearch
        ? searchProv.isLoading
        : myProv.isLoading;

    // Use hardware coordinates or default Jammu
    final LatLng deviceLatLng = activeTelemetry?.latitude != null
        ? LatLng(activeTelemetry!.latitude!, activeTelemetry!.longitude!)
        : const LatLng(32.9090, 74.8016);

    // AUTO-PAN CAMERA (Post-Frame to avoid build loops)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (activeTelemetry?.latitude != null && !isLoadingData) {
        _mapController.move(deviceLatLng, _currentZoom);
      }
    });

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(), // Original Focus System
      child: Scaffold(
        key: _scaffoldKey,
        endDrawer: const MyProfileDrawer(),
        body: Stack(
          children: [
            // --- MAP LAYER ---
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: deviceLatLng,
                initialZoom: _currentZoom,
                onPositionChanged: (pos, gesture) {
                  if (pos.zoom != _currentZoom) _currentZoom = pos.zoom;
                  if (gesture)
                    FocusScope.of(context).unfocus(); // Unfocus on pan
                },
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://api.maptiler.com/maps/openstreetmap/{z}/{x}/{y}.png?key=uOv6PI7AYa13sqD3rQbo',
                  userAgentPackageName: 'com.synquerra.app',
                ),
                if (activeTelemetry != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: deviceLatLng,
                        width: 80,
                        height: 80,
                        child: const Icon(
                          Icons.location_pin,
                          color: Colors.red,
                          size: 40,
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

            // --- SEARCH BAR (Visual Style Reinstated) ---
            Positioned(
              top: MediaQuery.of(context).padding.top + 10,
              left: 10,
              right: 10,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.0),
                        child: Icon(Icons.search, color: Colors.grey),
                      ),
                      Expanded(
                        child: Autocomplete<String>(
                          key: ValueKey(_hasLoadedImeis),
                          optionsBuilder: (val) async {
                            if (!_hasLoadedImeis) {
                              _loadImeis();
                              return const Iterable<String>.empty();
                            }
                            if (val.text == '') return _allImeis.take(5);
                            return _allImeis
                                .where((i) => i.contains(val.text))
                                .take(5);
                          },
                          onSelected: (selection) =>
                              _navigateToDetails(selection),
                          optionsViewBuilder: (context, onSelected, options) {
                            return Align(
                              alignment: Alignment.topLeft,
                              child: Material(
                                elevation: 4.0,
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  width:
                                      MediaQuery.of(context).size.width -
                                      100, // Matching old code look
                                  constraints: const BoxConstraints(
                                    maxHeight: 250,
                                  ),
                                  child: ListView.builder(
                                    padding: EdgeInsets.zero,
                                    shrinkWrap: true,
                                    itemCount: options.length,
                                    itemBuilder: (ctx, idx) => ListTile(
                                      leading: const Icon(
                                        Icons.history,
                                        color: Colors.grey,
                                        size: 20,
                                      ),
                                      title: Text(options.elementAt(idx)),
                                      onTap: () =>
                                          onSelected(options.elementAt(idx)),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                          fieldViewBuilder: (ctx, ctrl, node, onSub) {
                            return TextField(
                              controller: ctrl,
                              focusNode: node,
                              textInputAction: TextInputAction.search,
                              onSubmitted: (v) => _navigateToDetails(v),
                              decoration: InputDecoration(
                                hintText: _isLoadingImeis
                                    ? "Loading..."
                                    : "Search Device by IMEI",
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                              ),
                            );
                          },
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.person_outline),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.menu),
                        onPressed: () =>
                            _scaffoldKey.currentState?.openEndDrawer(),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // --- ZOOM CONTROLS ---
            Positioned(
              top: MediaQuery.of(context).padding.top + 130,
              right: 10,
              child: _buildZoomControls(colorScheme),
            ),

            // --- DATA SHEET ---
            DraggableScrollableSheet(
              initialChildSize: 0.15,
              minChildSize: 0.15,
              maxChildSize: 0.8,
              builder: (context, scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 15,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              showingSearch
                                  ? "Viewing Searched"
                                  : "Tracking ${user?.firstName ?? 'Leela'}",
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  "${activeTelemetry?.battery ?? '0'}%",
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.battery_full,
                                  color: Colors.green,
                                  size: 24,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          "Last Seen: ${activeTelemetry?.timestamp ?? 'Fetching...'}",
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      buildInfoRow(
                        context,
                        icon: Icons.location_history,
                        label: "GEO Number:",
                        value: "3",
                        valueSuffix: " Safe Zone",
                        valueSuffixColor: Colors.green,
                        theme: theme,
                      ),
                      buildInfoRow(
                        context,
                        icon: Icons.score,
                        label: "GPS Score:",
                        value: "${activeHealth?.gpsScore.toInt() ?? 0}",
                        valueSuffix: " / 100",
                        valueSuffixColor: Colors.blue,
                        theme: theme,
                      ),
                      buildInfoRow(
                        context,
                        icon: Icons.speed,
                        label: "${activeTelemetry?.speed ?? 0.0} Km/hr",
                        value:
                            "${activeTelemetry?.temperature?.replaceAll('c', '').trim() ?? '32'}°C",
                        theme: theme,
                      ),
                      buildInfoRow(
                        context,
                        icon: Icons.signal_cellular_alt,
                        label: "SIM 1",
                        value: "Signal Strength: ",
                        valueSuffix: "${activeTelemetry?.signal ?? 74}%",
                        valueSuffixColor: Colors.green,
                        theme: theme,
                      ),
                      buildInfoRow(
                        context,
                        icon: Icons.sos,
                        label: "SOS",
                        value: "Enable",
                        theme: theme,
                      ),

                      const SizedBox(height: 20),
                      const Divider(indent: 60, endIndent: 60),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          "Guardian Contacts:",
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      buildContactCard(
                        context,
                        name: "${user?.firstName} ${user?.lastName}",
                        phoneNumber: user?.mobile ?? "N/A",
                        email: user?.email ?? "N/A",
                        theme: theme,
                      ),

                      const Divider(indent: 60, endIndent: 60),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          "Device Details",
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      buildInfoRow(
                        context,
                        icon: Icons.devices,
                        label: "IMEI (Device):",
                        value: user?.imei ?? "---",
                        theme: theme,
                      ),
                      buildInfoRow(
                        context,
                        icon: Icons.memory,
                        label: "Firmware:",
                        value: "1dfv3515",
                        theme: theme,
                      ),

                      if (showingSearch)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: ElevatedButton(
                            onPressed: () => context
                                .read<SearchedDeviceProvider>()
                                .clearSearch(),
                            child: const Text("Return to My Device"),
                          ),
                        ),
                      const SizedBox(height: 100),
                    ],
                  ),
                );
              },
            ),

            // --- LOADING SCREEN OVERLAY (NEW Feature) ---
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
    );
  }

  Widget _buildZoomControls(ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            blurRadius: 4,
            color: Colors.black26,
            offset: const Offset(0, 2),
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

  Widget buildInfoRow(
    BuildContext context, {
    required String label,
    required String value,
    IconData? icon,
    String? valueSuffix,
    Color? valueSuffixColor,
    required ThemeData theme,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Row(
        children: [
          if (icon != null)
            Icon(
              icon,
              size: 20,
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
            ),
          const SizedBox(width: 10),
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontSize: 18,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Text(
                  value,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontSize: 18,
                    color: valueColor ?? theme.colorScheme.onSurface,
                  ),
                ),
                if (valueSuffix != null)
                  Text(
                    valueSuffix,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: valueSuffixColor ?? theme.colorScheme.onSurface,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildContactCard(
    BuildContext context, {
    required String name,
    required String phoneNumber,
    required String email,
    required ThemeData theme,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  phoneNumber,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontSize: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  email,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontSize: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.call, color: Colors.white),
            style: IconButton.styleFrom(backgroundColor: theme.primaryColor),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}








// --------------------------------------------------------------------------------------------------------------
// working but without search





// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:latlong2/latlong.dart';
// import 'package:provider/provider.dart';
// import 'package:flutter_map_compass/flutter_map_compass.dart';
// import 'package:synquerra/providers/user_provider.dart'; // NEW
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

//   // Search Logic (UI State)
//   List<String> _allImeis = [];
//   bool _isLoadingImeis = false;
//   bool _hasLoadedImeis = false;
//   final FocusNode _searchFocusNode = FocusNode();

//   @override
//   void initState() {
//     super.initState();
//     // OPTIMAL: Load user and IMEIs once via Providers/Microtasks
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final userProv = context.read<UserProvider>();
//       userProv.initUser().then((_) {
//         if (userProv.user?.imei != null) {
//           context.read<DeviceProvider>().refreshMyDevice(userProv.user!.imei);
//         }
//       });
//     });

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
//       print("--- [DEBUG] Fetching All Device IMEIs ---");
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
//     FocusScope.of(context).unfocus();
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

//     // Listen to Session and Data Providers
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
//     final isLoading = showingSearch ? searchProv.isLoading : myProv.isLoading;

//     final LatLng deviceLatLng = activeTelemetry?.latitude != null
//         ? LatLng(activeTelemetry!.latitude!, activeTelemetry!.longitude!)
//         : const LatLng(32.9090, 74.8016);

//     // AUTO-MOVE CAMERA
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (activeTelemetry?.latitude != null && !isLoading) {
//         _mapController.move(deviceLatLng, _currentZoom);
//       }
//     });

//     return GestureDetector(
//       onTap: () => FocusScope.of(context).unfocus(),
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
//                         width: 60,
//                         height: 60,
//                         child: const Icon(
//                           Icons.location_pin,
//                           color: Colors.red,
//                           size: 45,
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

//             // --- SEARCH BAR (STRUCTURAL FIX) ---
//             Positioned(
//               top: MediaQuery.of(context).padding.top + 10,
//               left: 10,
//               right: 10,
//               child: _buildSearchBar(colorScheme),
//             ),

//             // --- ZOOM CONTROLS ---
//             Positioned(
//               top: MediaQuery.of(context).padding.top + 130,
//               right: 10,
//               child: _buildZoomControls(colorScheme),
//             ),

//             if (isLoading)
//               const Positioned(
//                 top: 80,
//                 left: 0,
//                 right: 0,
//                 child: LinearProgressIndicator(),
//               ),

//             // --- DATA SHEET (FULL FIELDS RESTORED) ---
//             DraggableScrollableSheet(
//               initialChildSize: 0.2,
//               minChildSize: 0.15,
//               maxChildSize: 0.9,
//               builder: (context, scrollController) {
//                 return Container(
//                   decoration: BoxDecoration(
//                     color: colorScheme.surface,
//                     borderRadius: const BorderRadius.vertical(
//                       top: Radius.circular(25),
//                     ),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.2),
//                         blurRadius: 10,
//                       ),
//                     ],
//                   ),
//                   child: ListView(
//                     controller: scrollController,
//                     padding: const EdgeInsets.all(16),
//                     children: [
//                       Center(
//                         child: Container(
//                           width: 40,
//                           height: 4,
//                           decoration: BoxDecoration(
//                             color: Colors.grey[300],
//                             borderRadius: BorderRadius.circular(2),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 20),

//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Flexible(
//                             child: Text(
//                               showingSearch
//                                   ? "Viewing Searched"
//                                   : "Tracking ${user?.firstName ?? 'User'}",
//                               style: theme.textTheme.headlineSmall?.copyWith(
//                                 fontWeight: FontWeight.bold,
//                               ),
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                           ),
//                           Row(
//                             children: [
//                               Text(
//                                 "${activeTelemetry?.battery ?? '0'}%",
//                                 style: const TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                               const SizedBox(width: 4),
//                               const Icon(
//                                 Icons.battery_full,
//                                 color: Colors.green,
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                       Text(
//                         "Last Seen: ${activeTelemetry?.timestamp ?? 'Fetching...'}",
//                         style: TextStyle(color: Colors.grey[600]),
//                       ),
//                       const Divider(height: 32),

//                       // Restored Fields
//                       buildInfoRow(
//                         context,
//                         icon: Icons.person_outline,
//                         label: "User Id:",
//                         value: user?.uniqueId ?? "---",
//                         theme: theme,
//                       ),
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
//                         label: "28 Km/hr",
//                         value:
//                             "${activeTelemetry?.temperature?.replaceAll('c', '').trim() ?? '32'}°C",
//                         theme: theme,
//                       ),
//                       buildInfoRow(
//                         context,
//                         icon: Icons.sim_card,
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
//                       const Divider(),
//                       const SizedBox(height: 10),
//                       Text(
//                         "Guardian Contacts:",
//                         style: theme.textTheme.titleMedium?.copyWith(
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       buildContactCard(
//                         context,
//                         name: "${user?.firstName} ${user?.lastName}",
//                         phoneNumber: user?.mobile ?? "N/A",
//                         email: user?.email ?? "N/A",
//                         theme: theme,
//                       ),

//                       const SizedBox(height: 20),
//                       const Divider(),
//                       Text(
//                         "Device Details",
//                         style: theme.textTheme.titleMedium?.copyWith(
//                           fontWeight: FontWeight.bold,
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
//                       buildInfoRow(
//                         context,
//                         icon: Icons.qr_code,
//                         label: "Profile Code:",
//                         value: "14683515",
//                         theme: theme,
//                       ),

//                       if (showingSearch)
//                         Padding(
//                           padding: const EdgeInsets.symmetric(vertical: 16.0),
//                           child: ElevatedButton.icon(
//                             icon: const Icon(Icons.close),
//                             label: const Text("Return to My Device"),
//                             onPressed: () => context
//                                 .read<SearchedDeviceProvider>()
//                                 .clearSearch(),
//                           ),
//                         ),
//                       const SizedBox(height: 100),
//                     ],
//                   ),
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // --- REPAIRED BUILDINFO ROW (PREVENTS OVERFLOW) ---
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
//       padding: const EdgeInsets.symmetric(vertical: 6.0),
//       child: Row(
//         children: [
//           if (icon != null) Icon(icon, size: 20, color: Colors.grey[600]),
//           const SizedBox(width: 12),
//           SizedBox(
//             width: 110,
//             child: Text(
//               label,
//               style: const TextStyle(color: Colors.grey, fontSize: 16),
//             ),
//           ),
//           Expanded(
//             child: Row(
//               children: [
//                 Flexible(
//                   child: Text(
//                     value,
//                     style: const TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 17,
//                     ),
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ),
//                 if (valueSuffix != null)
//                   Text(
//                     valueSuffix,
//                     style: TextStyle(
//                       color: valueSuffixColor ?? Colors.blue,
//                       fontWeight: FontWeight.bold,
//                       fontSize: 17,
//                     ),
//                   ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // --- RESTORED WORKING SEARCH BAR ---
//   Widget _buildSearchBar(ColorScheme colorScheme) {
//     return Material(
//       elevation: 4,
//       borderRadius: BorderRadius.circular(30),
//       child: Container(
//         decoration: BoxDecoration(
//           color: colorScheme.surface,
//           borderRadius: BorderRadius.circular(30),
//         ),
//         child: Row(
//           children: [
//             const Padding(
//               padding: EdgeInsets.symmetric(horizontal: 12.0),
//               child: Icon(Icons.search, color: Colors.grey),
//             ),
//             Expanded(
//               child: LayoutBuilder(
//                 builder: (context, constraints) {
//                   return Autocomplete<String>(
//                     optionsBuilder: (TextEditingValue val) {
//                       if (val.text == '') return _allImeis.take(5);
//                       return _allImeis
//                           .where((i) => i.contains(val.text))
//                           .take(5);
//                     },
//                     onSelected: _navigateToDetails,
//                     optionsViewBuilder: (context, onSelected, options) {
//                       return Align(
//                         alignment: Alignment.topLeft,
//                         child: Material(
//                           elevation: 4.0,
//                           child: Container(
//                             width: constraints.maxWidth,
//                             color: colorScheme.surface,
//                             constraints: const BoxConstraints(maxHeight: 200),
//                             child: ListView.builder(
//                               padding: EdgeInsets.zero,
//                               itemCount: options.length,
//                               itemBuilder: (ctx, idx) => ListTile(
//                                 leading: const Icon(Icons.history, size: 20),
//                                 title: Text(options.elementAt(idx)),
//                                 onTap: () => onSelected(options.elementAt(idx)),
//                               ),
//                             ),
//                           ),
//                         ),
//                       );
//                     },
//                     fieldViewBuilder: (ctx, ctrl, focus, onSub) {
//                       return TextField(
//                         controller: ctrl,
//                         focusNode: focus,
//                         decoration: const InputDecoration(
//                           hintText: "Search Device by IMEI",
//                           border: InputBorder.none,
//                         ),
//                       );
//                     },
//                   );
//                 },
//               ),
//             ),
//             IconButton(
//               icon: const Icon(Icons.menu),
//               onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
//             ),
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
//         children: [
//           IconButton(
//             icon: const Icon(Icons.add),
//             onPressed: () {
//               setState(() {
//                 _currentZoom++;
//                 _mapController.move(_mapController.camera.center, _currentZoom);
//               });
//             },
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
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: Row(
//         children: [
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   name,
//                   style: const TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 18,
//                   ),
//                 ),
//                 Text(phoneNumber, style: TextStyle(color: Colors.grey[600])),
//                 Text(email, style: TextStyle(color: Colors.grey[600])),
//               ],
//             ),
//           ),
//           IconButton(
//             icon: const Icon(Icons.call, color: Colors.blue),
//             onPressed: () {},
//           ),
//           IconButton(
//             icon: const Icon(Icons.mail, color: Colors.teal),
//             onPressed: () {},
//           ),
//         ],
//       ),
//     );
//   }
// }
























//--------------------------------------------------------------------------------------------------------------
// Working code





// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:latlong2/latlong.dart';
// import 'package:location/location.dart';
// import 'package:flutter_map_compass/flutter_map_compass.dart';
// import 'package:synquerra/core/models/analytics_model.dart';
// import 'package:synquerra/screens/landing/home/details/data_telemetry_screen.dart';
// // import 'package:synquerra/screens/landing/home/details/detail_screen.dart';
// import '../../core/services/device_service.dart';
// import '../../screens/landing/home/my_profile_drawer.dart'; // Your existing drawer

// import '../../core/models/user_model.dart';
// import '../../core/services/user_preferences.dart';

// class MapScreen extends StatefulWidget {
//   const MapScreen({super.key});

//   @override
//   State<MapScreen> createState() => _MapScreenState();
// }

// class _MapScreenState extends State<MapScreen> {
//   // Key to access Scaffold for opening drawera
//   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

//   LocationData? _currentLocation;
//   final MapController _mapController = MapController();
//   double _currentZoom = 13;

//   UserData? _currentUser;

//   // Add these to your state variables
//   AnalyticsData? _latestTelemetry;
//   AnalyticsHealth? _healthData;
//   bool _isFetchingDeviceData = false;

//   List<String> _allImeis = [];

//   bool _isLoadingImeis = false;
//   bool _hasLoadedImeis = false;

//   final FocusNode _searchFocusNode = FocusNode();

//   @override
//   void initState() {
//     super.initState();
//     _fetchLocationAndMove();

//     _loadUserData();

//     _searchFocusNode.addListener(() {
//       if (_searchFocusNode.hasFocus && !_hasLoadedImeis) {
//         _loadImeis();
//       }
//     });

//     // _loadImeis();
//   }

//   @override
//   void dispose() {
//     _searchFocusNode.dispose();
//     super.dispose();
//   }

//   Future<void> _loadUserData() async {
//     print("--- DEBUG: Initializing User Load ---");
//     final user = await UserPreferences().getUser();

//     if (user == null) {
//       print("--- DEBUG: No user object found in Preferences ---");
//       return;
//     }

//     print("--- DEBUG: User found. IMEI in storage: '${user.imei}' ---");

//     if (user.imei.isEmpty) {
//       print(
//         "--- DEBUG: WARNING - User IMEI is empty! API calls will be skipped. ---",
//       );
//       // If IMEI is empty, we still want to show the user's name/email in the UI
//       if (mounted) setState(() => _currentUser = user);
//       return;
//     }

//     if (mounted) {
//       setState(() {
//         _currentUser = user;
//       });
//       // IMEI is confirmed, now fetch the live device data
//       _fetchDeviceData(user.imei);
//     }
//   }

//   Future<void> _fetchDeviceData(String imei) async {
//     print("--- DEBUG: Fetching telemetry for IMEI: $imei ---");
//     setState(() => _isFetchingDeviceData = true);

//     try {
//       final results = await Future.wait([
//         DeviceService().getAnalyticsByImei(imei),
//         DeviceService().getHealth(imei),
//       ]);

//       final List<AnalyticsData> packets = results[0] as List<AnalyticsData>;
//       final AnalyticsHealth health = results[1] as AnalyticsHealth;

//       print("--- DEBUG: Data Received. Packets: ${packets.length} ---");

//       if (mounted) {
//         setState(() {
//           _latestTelemetry = packets.isNotEmpty ? packets.last : null;
//           _healthData = health;
//           _isFetchingDeviceData = false;
//         });
//         print("--- DEBUG: UI State updated with new telemetry ---");
//       }
//       if (_latestTelemetry?.latitude != null) {
//         _mapController.move(
//           LatLng(_latestTelemetry!.latitude!, _latestTelemetry!.longitude!),
//           _currentZoom,
//         );
//       }
//     } catch (e) {
//       print("--- DEBUG: Fetch Error: $e ---");
//       if (mounted) setState(() => _isFetchingDeviceData = false);
//     }
//   }

//   Future<void> _loadImeis() async {
//     if (_hasLoadedImeis || _isLoadingImeis) return;
//     setState(() {
//       _isLoadingImeis = true;
//     });
//     print("Starting to load IMEIs..."); // DEBUG 1
//     try {
//       final imeis = await DeviceService().getDeviceImeis();
//       print("Loaded IMEIs: $imeis"); // DEBUG 2
//       if (mounted) {
//         setState(() {
//           _allImeis = imeis;
//           _hasLoadedImeis = true;
//           _isLoadingImeis = false;
//         });
//       }
//     } catch (e) {
//       print("Failed to load IMEIs: $e"); // DEBUG 3
//       if (mounted) setState(() => _isLoadingImeis = false);
//     }
//   }

//   void _navigateToDetails(String imei) {
//     if (imei.isEmpty) return;

//     FocusScope.of(context).unfocus(); // Close keyboard
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (_) => DataTelemetryScreen(imei: imei)),
//     );
//   }

//   // Combines fetching location and moving the map
//   Future<void> _fetchLocationAndMove() async {
//     Location location = Location();
//     bool serviceEnabled;
//     PermissionStatus permissionGranted;

//     // Check and request service
//     serviceEnabled = await location.serviceEnabled();
//     if (!serviceEnabled) {
//       serviceEnabled = await location.requestService();
//       if (!serviceEnabled) {
//         if (mounted) _showErrorSnackBar('Location services are disabled.');
//         return;
//       }
//     }

//     // Check and request permission
//     permissionGranted = await location.hasPermission();
//     if (permissionGranted == PermissionStatus.denied) {
//       permissionGranted = await location.requestPermission();
//       if (permissionGranted != PermissionStatus.granted) {
//         if (mounted) _showErrorSnackBar('Location permission denied.');
//         return;
//       }
//     }

//     try {
//       LocationData locationData = await location.getLocation();
//       if (mounted) {
//         setState(() {
//           _currentLocation = locationData;
//         });
//         _goToCurrentLocation(animate: false);
//       }
//     } catch (e) {
//       print("Error fetching location: $e");
//       if (mounted) {
//         _showErrorSnackBar('Could not fetch location. Please try again.');
//       }
//     }
//   }

//   // Helper to show snackbar messages
//   void _showErrorSnackBar(String message) {
//     ScaffoldMessenger.of(
//       context,
//     ).showSnackBar(SnackBar(content: Text(message)));
//   }

//   void _goToCurrentLocation({bool animate = true}) {
//     if (_currentLocation != null) {
//       // Use moveAndRotate for smoother transitions if needed later
//       _mapController.move(
//         LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
//         _currentZoom,
//       );
//     } else {
//       _showErrorSnackBar('Current location not available yet.');
//     }
//   }

//   void _zoomIn() {
//     setState(() {
//       _currentZoom = (_currentZoom + 1).clamp(1.0, 18.0);
//       _mapController.move(_mapController.camera.center, _currentZoom);
//     });
//   }

//   void _zoomOut() {
//     setState(() {
//       _currentZoom = (_currentZoom - 1).clamp(1.0, 18.0);
//       _mapController.move(_mapController.camera.center, _currentZoom);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final colorScheme = theme.colorScheme;

//     return GestureDetector(
//       onTap: () => FocusScope.of(context).unfocus(),
//       child: Scaffold(
//         key: _scaffoldKey,
//         endDrawer: const MyProfileDrawer(),
//         body: Stack(
//           children: [
//             // --- MAP BACKGROUND ---
//             FlutterMap(
//               mapController: _mapController,
//               options: MapOptions(
//                 initialCenter: _currentLocation != null
//                     ? LatLng(
//                         _currentLocation!.latitude!,
//                         _currentLocation!.longitude!,
//                       )
//                     : const LatLng(32.9090, 74.8016), // Dudura, Jammu
//                 initialZoom: _currentZoom,
//                 minZoom: 3,
//                 maxZoom: 18,
//                 onPositionChanged: (position, hasGesture) {
//                   if (position.zoom != _currentZoom) {
//                     if (mounted) {
//                       setState(() {
//                         _currentZoom = position.zoom;
//                       });
//                     }
//                   }
//                   if (hasGesture) FocusScope.of(context).unfocus();
//                 },
//               ),
//               children: [
//                 TileLayer(
//                   urlTemplate:
//                       'https://api.maptiler.com/maps/openstreetmap/{z}/{x}/{y}.png?key=uOv6PI7AYa13sqD3rQbo', // Your corrected MapTiler URL
//                   userAgentPackageName: 'com.synquerra.app',
//                 ),
//                 if (_currentLocation != null)
//                   MarkerLayer(
//                     markers: [
//                       Marker(
//                         point: LatLng(
//                           _currentLocation!.latitude!,
//                           _currentLocation!.longitude!,
//                         ),
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

//                 // --- MOVED MapCompass INSIDE FlutterMap's children ---
//                 MapCompass(
//                   icon: Icon(
//                     Icons.explore_outlined,
//                     size: 36,
//                     // Use theme color for compass icon
//                     color: Colors.black87,
//                   ),
//                   hideIfRotatedNorth: true,
//                   alignment: Alignment.topRight, // Position within the map
//                   padding: const EdgeInsets.only(
//                     top: 110,
//                     right: 10,
//                   ), // Adjust padding as needed relative to map edges
//                 ),
//                 // --------------------------------------------------------
//               ],
//             ),

//             // --- TOP SEARCH BAR AREA ---
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
//                         child: LayoutBuilder(
//                           builder: (context, constraints) {
//                             return Autocomplete<String>(
//                               key: ValueKey(_hasLoadedImeis),
//                               // A. Define Options
//                               optionsBuilder:
//                                   (TextEditingValue textEditingValue) async {
//                                     // Trigger load if not loaded yet
//                                     if (!_hasLoadedImeis) {
//                                       _loadImeis();
//                                       // Return empty while loading to avoid errors
//                                       return const Iterable<String>.empty();
//                                     }

//                                     if (textEditingValue.text == '') {
//                                       return _allImeis.take(
//                                         5,
//                                       ); // Show top 5 recent/all
//                                     }
//                                     return _allImeis
//                                         .where((String imei) {
//                                           return imei.contains(
//                                             textEditingValue.text,
//                                           );
//                                         })
//                                         .take(5);
//                                   },

//                               // B. Selection Handler
//                               onSelected: (String selection) {
//                                 _navigateToDetails(selection);
//                               },

//                               // C. Input Field
//                               fieldViewBuilder:
//                                   (
//                                     context,
//                                     textController,
//                                     focusNode,
//                                     onFieldSubmitted,
//                                   ) {
//                                     // Trigger load when focused
//                                     if (focusNode.hasFocus &&
//                                         !_hasLoadedImeis) {
//                                       _loadImeis();
//                                     }

//                                     return TextField(
//                                       controller: textController,
//                                       focusNode: focusNode,
//                                       // --- FIX 2: Handle Keyboard "Go/Search" button ---
//                                       textInputAction: TextInputAction.search,
//                                       onSubmitted: (value) {
//                                         // If text matches an IMEI exactly, go there.
//                                         // Or simply pass whatever text is there to the details screen logic
//                                         _navigateToDetails(value);
//                                       },
//                                       decoration: InputDecoration(
//                                         hintText: _isLoadingImeis
//                                             ? "Loading..."
//                                             : "Search Device by IMEI",
//                                         border: InputBorder.none,
//                                         contentPadding: EdgeInsets.zero,
//                                       ),
//                                     );
//                                   },

//                               // D. Dropdown List View
//                               optionsViewBuilder: (context, onSelected, options) {
//                                 return Align(
//                                   alignment: Alignment.topLeft,
//                                   child: Material(
//                                     elevation: 4.0,
//                                     color: colorScheme.surface,
//                                     borderRadius: BorderRadius.circular(20),
//                                     child: Container(
//                                       width: constraints.maxWidth,
//                                       constraints: const BoxConstraints(
//                                         maxHeight: 250,
//                                       ),
//                                       child: ListView.builder(
//                                         padding: EdgeInsets.zero,
//                                         shrinkWrap: true,
//                                         itemCount: options.length,
//                                         itemBuilder:
//                                             (BuildContext context, int index) {
//                                               final String option = options
//                                                   .elementAt(index);
//                                               return ListTile(
//                                                 leading: const Icon(
//                                                   Icons.history,
//                                                   size: 20,
//                                                   color: Colors.grey,
//                                                 ), // Add icon for better look
//                                                 title: Text(option),
//                                                 onTap: () => onSelected(option),
//                                               );
//                                             },
//                                       ),
//                                     ),
//                                   ),
//                                 );
//                               },
//                             );
//                           },
//                         ),
//                       ),
//                       IconButton(
//                         icon: Icon(
//                           Icons.person_outline,
//                           color: colorScheme.onSurfaceVariant,
//                         ),
//                         onPressed: () {
//                           print("Profile icon tapped");
//                         },
//                       ),
//                       IconButton(
//                         icon: Icon(
//                           Icons.menu,
//                           color: colorScheme.onSurfaceVariant,
//                         ),
//                         onPressed: () =>
//                             _scaffoldKey.currentState?.openEndDrawer(),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),

//             // --- ZOOM CONTROLS (Removed Compass from here) ---
//             Positioned(
//               // Adjust top position now that compass is removed
//               top:
//                   MediaQuery.of(context).padding.top +
//                   130, // Example adjustment
//               right: 10,
//               child: Container(
//                 // Keep zoom buttons together
//                 decoration: BoxDecoration(
//                   color: colorScheme.surface.withOpacity(0.9),
//                   borderRadius: BorderRadius.circular(20),
//                   boxShadow: [
//                     BoxShadow(
//                       blurRadius: 4,
//                       color: Colors.black26,
//                       offset: Offset(0, 2),
//                     ),
//                   ],
//                 ),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     IconButton(
//                       icon: Icon(Icons.add, color: colorScheme.onSurface),
//                       onPressed: _zoomIn,
//                       iconSize: 28,
//                     ),
//                     Divider(
//                       height: 1,
//                       thickness: 1,
//                       indent: 5,
//                       endIndent: 5,
//                       color: colorScheme.outlineVariant,
//                     ),
//                     IconButton(
//                       icon: Icon(Icons.remove, color: colorScheme.onSurface),
//                       onPressed: _zoomOut,
//                       iconSize: 28,
//                     ),
//                   ],
//                 ),
//               ),
//             ),

//             // --- CURRENT LOCATION BUTTON ---
//             Positioned(
//               bottom: MediaQuery.of(context).size.height * 0.15 + 20,
//               right: 16,
//               child: FloatingActionButton(
//                 onPressed: _goToCurrentLocation,
//                 backgroundColor: theme.primaryColor,
//                 child: const Icon(Icons.my_location, color: Colors.white),
//               ),
//             ),

//             // --- BOTTOM DRAGGABLE SHEET ---
//             // --- BOTTOM DRAGGABLE SHEET ---
//             // --- BOTTOM DRAGGABLE SHEET ---
//             DraggableScrollableSheet(
//               initialChildSize: 0.15,
//               minChildSize: 0.15,
//               maxChildSize: 0.8,
//               builder: (BuildContext context, ScrollController scrollController) {
//                 return Container(
//                   decoration: BoxDecoration(
//                     color: colorScheme.surface,
//                     borderRadius: const BorderRadius.only(
//                       topLeft: Radius.circular(20),
//                       topRight: Radius.circular(20),
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
//                       // Drag Handle
//                       Center(
//                         child: Container(
//                           width: 40,
//                           height: 5,
//                           margin: const EdgeInsets.only(bottom: 10),
//                           decoration: BoxDecoration(
//                             color: Colors.grey[300],
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                         ),
//                       ),

//                       // --- HEADER: Tracking Name ---
//                       Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text(
//                               "Tracking ${_currentUser?.firstName ?? 'Leela'}", // Dynamic Name
//                               style: theme.textTheme.titleLarge?.copyWith(
//                                 fontSize: 24,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             Row(
//                               children: [
//                                 Text(
//                                   "${_latestTelemetry?.battery ?? '0'}%",
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
//                           "Last Login: ${_currentUser?.lastLoginAt ?? '2026-01-13 16:11:35'}",
//                           style: theme.textTheme.bodyLarge?.copyWith(
//                             color: colorScheme.onSurfaceVariant,
//                             fontSize: 18,
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 12),

//                       // --- PLACEHOLDERS & DYNAMIC FIELDS ---

//                       // Static Placeholder
//                       buildInfoRow(
//                         context,
//                         icon: Icons.location_history,
//                         label: "GEO Number:",
//                         value: "3",
//                         valueSuffix: " Safe Zone",
//                         valueSuffixColor: Colors.green,
//                         theme: theme,
//                       ),

//                       // Dynamic GPS Score
//                       buildInfoRow(
//                         context,
//                         icon: Icons.score,
//                         label: "GPS Score:",
//                         value: "${_healthData?.gpsScore.toInt() ?? 0}",
//                         valueSuffix: " / 100",
//                         valueSuffixColor: Colors.blue,
//                         theme: theme,
//                       ),

//                       // Static Placeholder (from your original screen)
//                       buildInfoRow(
//                         context,
//                         icon: Icons.speed,
//                         label: "28 Km/hr",
//                         value: "32°C",
//                         theme: theme,
//                       ),

//                       // Dynamic Speed & Temp
//                       buildInfoRow(
//                         context,
//                         icon: Icons.sensors,
//                         label: "${_latestTelemetry?.speed ?? 0.0} Km/hr",
//                         value: _latestTelemetry?.temperature != null
//                             ? "${_latestTelemetry!.temperature!.toLowerCase().replaceAll('c', '').trim()}°C"
//                             : "--",
//                         theme: theme,
//                       ),

//                       // Static SIM Placeholder
//                       buildInfoRow(
//                         context,
//                         icon: Icons.signal_cellular_alt,
//                         label: "SIM 1",
//                         value: "Signal Strength: ",
//                         valueSuffix: "${_latestTelemetry?.signal ?? 0}%",
//                         valueSuffixColor: Colors.green,
//                         theme: theme,
//                       ),

//                       // Static SOS Placeholder
//                       buildInfoRow(
//                         context,
//                         icon: Icons.sos,
//                         label: "SOS",
//                         value: "Enable",
//                         theme: theme,
//                       ),

//                       const SizedBox(height: 20),
//                       const Divider(indent: 60, endIndent: 60),
//                       const SizedBox(height: 20),

//                       // --- Guardian Contacts ---
//                       Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
//                         name:
//                             "${_currentUser?.firstName ?? 'Leela'} ${_currentUser?.lastName ?? 'Bhalla'}",
//                         phoneNumber: _currentUser?.mobile ?? '74*****209',
//                         email: _currentUser?.email ?? 'li***@example.com',
//                         theme: theme,
//                       ),

//                       const SizedBox(height: 20),
//                       const Divider(indent: 60, endIndent: 60),

//                       // --- Device Details ---
//                       Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
//                         value: _currentUser?.imei ?? '168418618486',
//                         theme: theme,
//                       ),
//                       buildInfoRow(
//                         context,
//                         icon: Icons.memory,
//                         label: "Firmware:",
//                         value: "1dfv3515",
//                         theme: theme,
//                       ),
//                       const SizedBox(height: 100),
//                     ],
//                   ),
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // --- Helper Widget for Info Rows ---
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
//     final colorScheme = theme.colorScheme;
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           if (icon != null)
//             Icon(
//               icon,
//               size: 20,
//               color: colorScheme.onSurfaceVariant.withOpacity(0.7),
//             ),
//           if (icon != null) const SizedBox(width: 10),
//           SizedBox(
//             width: 120, // Fixed width for labels for alignment
//             child: Text(
//               label,
//               style: theme.textTheme.bodyLarge?.copyWith(
//                 fontSize: 18, // Larger text
//                 color: colorScheme.onSurfaceVariant,
//               ),
//             ),
//           ),
//           Expanded(
//             child: Row(
//               children: [
//                 Text(
//                   value,
//                   style: theme.textTheme.bodyLarge?.copyWith(
//                     fontSize: 18, // Larger text
//                     color: valueColor ?? colorScheme.onSurface,
//                   ),
//                 ),
//                 if (valueSuffix != null)
//                   Text(
//                     valueSuffix,
//                     style: theme.textTheme.bodyLarge?.copyWith(
//                       fontSize: 18, // Larger text
//                       fontWeight: FontWeight.w600, // Make suffix bold
//                       color: valueSuffixColor ?? colorScheme.onSurface,
//                     ),
//                   ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // --- Helper Widget for Contact Cards ---
//   Widget buildContactCard(
//     BuildContext context, {
//     required String name,
//     required String phoneNumber,
//     required String email,
//     required ThemeData theme,
//   }) {
//     final colorScheme = theme.colorScheme;
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
//                     fontSize: 18, // Larger text
//                     fontWeight: FontWeight.bold,
//                     color: colorScheme.onSurface,
//                   ),
//                 ),
//                 Text(
//                   phoneNumber,
//                   style: theme.textTheme.bodyLarge?.copyWith(
//                     fontSize: 16, // Larger text
//                     color: colorScheme.onSurfaceVariant,
//                   ),
//                 ),
//                 Text(
//                   email,
//                   style: theme.textTheme.bodyLarge?.copyWith(
//                     fontSize: 16, // Larger text
//                     color: colorScheme.onSurfaceVariant,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Row(
//             children: [
//               // Call Button
//               Container(
//                 decoration: BoxDecoration(
//                   color: theme.primaryColor,
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: IconButton(
//                   icon: const Icon(Icons.call, color: Colors.white),
//                   onPressed: () {
//                     // TODO: Implement call functionality
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(
//                         content: Text('Calling!'), // Your message
//                         duration: Duration(
//                           seconds: 2,
//                         ), // How long it stays visible
//                         behavior: SnackBarBehavior
//                             .floating, // Makes it float above bottom nav bar (optional)
//                       ),
//                     );
//                   },
//                 ),
//               ),
//               const SizedBox(width: 8),
//               // MAil Button
//               Container(
//                 decoration: BoxDecoration(
//                   color: colorScheme
//                       .secondary, // Use a secondary color for message
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: IconButton(
//                   icon: const Icon(Icons.mail_rounded, color: Colors.white),
//                   onPressed: () {
//                     // TODO: Implement message functionality
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(
//                         content: Text('Mail sent!'), // Your message
//                         duration: Duration(
//                           seconds: 2,
//                         ), // How long it stays visible
//                         behavior: SnackBarBehavior
//                             .floating, // Makes it float above bottom nav bar (optional)
//                       ),
//                     );
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
