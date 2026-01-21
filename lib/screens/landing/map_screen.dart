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
  double _currentZoom = 16;

  List<String> _allImeis = [];
  bool _isLoadingImeis = false;
  bool _hasLoadedImeis = false;
  bool _showHistory = false;
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint("--- [MAP SCREEN] Initializing User Provider ---");
      final userProv = context.read<UserProvider>();

      if (userProv.user?.imei != null) {
        context.read<DeviceProvider>().refreshMyDevice(userProv.user!.imei);
      }
    });

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final myProv = context.watch<DeviceProvider>();
    final searchProv = context.watch<SearchedDeviceProvider>();

    if (myProv.errorMessage != null && !myProv.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(myProv.errorMessage!),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3), //
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

    final LatLng deviceLatLng = activeTelemetry?.latitude != null
        ? LatLng(activeTelemetry!.latitude!, activeTelemetry!.longitude!)
        : const LatLng(28.3702, 77.1236);

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
                                debugPrint(
                                  "Packet[$i]: Lat: ${p.latitude}, Lng: ${p.longitude} (Time: ${p.timestamp})",
                                );
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
