import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
// import 'dart:math' as math;
import 'package:flutter_map_compass/flutter_map_compass.dart';
import 'package:synquerra/core/services/update_device_service.dart';
import 'package:synquerra/providers/user_provider.dart';
import 'package:synquerra/providers/device_provider.dart';
import 'package:synquerra/providers/searched_device_provider.dart';
import 'package:synquerra/screens/landing/device_details_sheet.dart';
import 'package:synquerra/widgets/history_dot.dart';
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
  double _currentZoom = 16;

  List<String> _allImeis = [];
  bool _isLoadingImeis = false;
  bool _hasLoadedImeis = false;
  bool _showHistory = false;
  final FocusNode _searchFocusNode = FocusNode();

  bool _isRefreshingManually = false;
  // bool _isRefreshing = false;
  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   debugPrint("--- [MAP SCREEN] Initializing User Provider ---");
    //   debugPrint(
    //     "--- [MAP SCREEN] 1. initState: PostFrameCallback triggered ---",
    //   );
    //   final userProv = context.read<UserProvider>();

    //   if (userProv.user?.imei != null) {
    //     debugPrint(
    //       "--- [MAP SCREEN] 2. imei found: ${userProv.user!.imei}, calling refresh ---",
    //     );
    //     context.read<DeviceProvider>().refreshMyDevice(userProv.user!.imei);
    //   } else {
    //     debugPrint("--- [MAP SCREEN] ERROR: imei is NULL in initState ---");
    //   }
    // });

    _searchFocusNode.addListener(() {
      if (_searchFocusNode.hasFocus && !_hasLoadedImeis) _loadImeis();
    });
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _handleManualRefresh() async {
    final user = context.read<UserProvider>().user;
    // final deviceService = context.read<DeviceService>();
    final deviceProv = context.read<DeviceProvider>();
    final updateService = context.read<UpdateDeviceService>();

    if (user?.imei == null) return;

    setState(() => _isRefreshingManually = true);

    try {
      // 1. Direct Service Call (Fire and Forget)
      // No need to store this in Provider because it's a transient action
      final response = await updateService.queryNormal(
        imei: user!.imei,
        params: {},
      );

      if (response.status == 'SENT') {
        // 2. Short delay to allow the hardware/broker to process
        await Future.delayed(const Duration(seconds: 1));

        // 3. Provider Call (Update State)
        // This uses your optimized Background Isolate loop to refresh data
        await deviceProv.refreshMyDevice(user.imei);
      }
    } catch (e) {
      debugPrint("Refresh sequence failed: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Refresh failed: $e"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isRefreshingManually = false);
    }
  }

  Future<void> _loadImeis() async {
    if (_hasLoadedImeis || _isLoadingImeis) return;
    setState(() => _isLoadingImeis = true);
    try {
      final service = context.read<DeviceService>();
      final imeis = await service.getDeviceImeis();
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

  // lib/screens/landing/map_screen.dart

  void _showTimeSnippet(BuildContext context, String rawTime) {
    final packetTime = DateTime.parse(rawTime).toLocal();
    final timeLabel =
        "${packetTime.hour.toString().padLeft(2, '0')}:${packetTime.minute.toString().padLeft(2, '0')} on ${packetTime.day}/${packetTime.month}/${packetTime.year}";

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Device was here at $timeLabel"),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("--- [MAP SCREEN] 3. Building Widget Tree ---");
    final theme = Theme.of(context);
    // final user = context.watch<UserProvider>().user;
    final myProv = context.watch<DeviceProvider>();
    final searchProv = context.watch<SearchedDeviceProvider>();

    // if (user?.imei != null) {
    //   // The Provider now decides if work is actually needed.
    //   Future.microtask(
    //     () => context.read<DeviceProvider>().refreshMyDevice(user!.imei),
    //   );
    // }

    debugPrint(
      "--- [MAP SCREEN] 4. Provider State: isLoading=${myProv.isLoading}, hasError=${myProv.errorMessage != null} ---",
    );

    if (myProv.errorMessage != null && !myProv.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(myProv.errorMessage!),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2), //
          ),
        );
      });
    }

    final bool showingSearch = searchProv.currentImei != null;
    final activeTelemetry = showingSearch
        ? searchProv.latestTelemetry
        : myProv.latestTelemetry;
    final isLoadingData = showingSearch
        ? searchProv.isLoading
        : myProv.isLoading;

    final LatLng? deviceLatLng =
        (activeTelemetry?.latitude != null &&
            activeTelemetry?.longitude != null)
        ? LatLng(activeTelemetry!.latitude!, activeTelemetry!.longitude!)
        : null;

    final rawPackets = (showingSearch
        ? searchProv.allPackets
        : myProv.allPackets);

    final LatLng initialMapCenter =
        deviceLatLng ?? const LatLng(28.3702, 77.1236);

    // final now = DateTime.now();
    // final twentyFourHoursAgo = now.subtract(const Duration(hours: 24));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (activeTelemetry?.latitude != null && !isLoadingData) {
        _mapController.move(deviceLatLng!, _currentZoom);
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
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(
              bottom: 90.0,
            ), // Adjust based on your sheet height
            child: FloatingActionButton(
              backgroundColor: theme.colorScheme.primary,
              onPressed: _isRefreshingManually ? null : _handleManualRefresh,
              child: _isRefreshingManually
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.refresh, color: Colors.white),
            ),
          ),
          body: Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: initialMapCenter,
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
                  // --- 1. INTEGRATED HISTORY LAYER ---
                  // Inside FlutterMap children:
                  if (_showHistory && myProv.historyPoints.isNotEmpty) ...[
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: myProv.historyPoints,
                          strokeWidth: 3.0,
                          color: Colors.blue.withOpacity(0.4),
                        ),
                      ],
                    ),

                    MarkerLayer(
                      markers: List.generate(myProv.historyBearings.length, (
                        index,
                      ) {
                        // Raw Data from Provider
                        final point = myProv.historyPoints[index + 1];
                        final bearing = myProv.historyBearings[index];

                        return Marker(
                          point: point,
                          width: 20,
                          height: 20,
                          child: GestureDetector(
                            onTap: () => _showTimeSnippet(
                              context,
                              myProv.historyTimestamps[index],
                            ),
                            // The UI logic (HistoryDot) lives here in the View layer
                            child: Transform.rotate(
                              angle: myProv.historyBearings[index],
                              child: const Icon(
                                Icons.navigation,
                                color: Colors.blue,
                                size: 14,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),

                    // MarkerLayer(
                    //   markers: List.generate(myProv.historyBearings.length, (
                    //     index,
                    //   ) {
                    //     // We get the packet corresponding to this dot to show the time
                    //     // Index + 1 because the first point in historyPoints is the live location
                    //     final point = myProv.historyPoints[index + 1];

                    //     return Marker(
                    //       point: point,
                    //       width: 20,
                    //       height: 20,
                    //       child: GestureDetector(
                    //         behavior: HitTestBehavior.opaque,
                    //         onTap: () {
                    //           final rawTime = myProv.historyTimestamps[index];
                    //           final packetTime = DateTime.parse(
                    //             rawTime,
                    //           ).toLocal();

                    //           final timeLabel =
                    //               "${packetTime.hour.toString().padLeft(2, '0')}:${packetTime.minute.toString().padLeft(2, '0')} on ${packetTime.day}/${packetTime.month}/${packetTime.year}";
                    //           // Optional: Show a snackbar with the time for this specific dot
                    //           ScaffoldMessenger.of(context).showSnackBar(
                    //             SnackBar(
                    //               content: Text(
                    //                 "Device was here at $timeLabel",
                    //               ),
                    //               duration: const Duration(seconds: 1),
                    //               behavior: SnackBarBehavior.floating,
                    //               shape: RoundedRectangleBorder(
                    //                 borderRadius: BorderRadius.circular(10),
                    //               ),
                    //             ),
                    //           );
                    //         },
                    //         child: Transform.rotate(
                    //           angle: myProv.historyBearings[index],
                    //           child: const Icon(
                    //             Icons.navigation,
                    //             color: Colors.blue,
                    //             size: 14,
                    //           ),
                    //         ),
                    //       ),
                    //     );
                    //   }),
                    // ),
                  ],
                  // --- 2. LIVE DEVICE MARKER (Always on Top) ---
                  if (activeTelemetry != null)
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: deviceLatLng!,
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

                  // --- 3. CURRENT LIVE MARKER (Topmost Layer) ---
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
              if (isLoadingData || deviceLatLng == null)
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
                    // _loadImeis();
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
