import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
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

  Map<String, dynamic>? _cachedHistory;
  List<dynamic>? _lastPackets;

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

  double _getBearing(LatLng start, LatLng end) {
    double lat1 = start.latitude * math.pi / 180;
    double lon1 = start.longitude * math.pi / 180;
    double lat2 = end.latitude * math.pi / 180;
    double lon2 = end.longitude * math.pi / 180;

    double dLon = lon2 - lon1;
    double y = math.sin(dLon) * math.cos(lat2);
    double x =
        math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLon);
    return math.atan2(y, x);
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

  Map<String, dynamic> _getHistoryData(
    List<dynamic> packets,
    LatLng currentPos,
  ) {
    final now = DateTime.now();
    final cutoff = now.subtract(const Duration(hours: 24));
    List<LatLng> points = [currentPos];
    List<Marker> dots = [];

    // We add the current position as the start of our "line"
    // points.add(currentPos);
    debugPrint("--- [MAP HISTORY] Starting Line Build ---");
    debugPrint("Live Point: ${currentPos.latitude}, ${currentPos.longitude}");
    LatLng nextPoint = currentPos;

    // final int startIndex = packets.length > 1
    //     ? packets.length - 2
    //     : packets.length - 1;

    // Iterate backwards to get the most recent history first
    for (int i = packets.length - 5; i >= 0; i -= 5) {
      final p = packets[i];
      if (p.latitude == null || p.longitude == null || p.timestamp == null)
        continue;

      final packetTime = DateTime.parse(p.timestamp!).toLocal();
      if (packetTime.isBefore(cutoff)) break;

      final pos = LatLng(p.latitude!, p.longitude!);
      points.add(pos);
      debugPrint(
        "History Point [$i]: Lat: ${p.latitude}, Lng: ${p.longitude}, Time: ${p.timestamp}",
      );
      double rotation = _getBearing(pos, nextPoint);

      // Create a SMALLER dot
      dots.add(
        Marker(
          point: pos,
          width: 20, // Reduced size
          height: 20, // Reduced size
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              final timeLabel =
                  "${packetTime.hour.toString().padLeft(2, '0')}:${packetTime.minute.toString().padLeft(2, '0')} on ${packetTime.day}/${packetTime.month}/${packetTime.year}";
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Device was here at $timeLabel"),
                  behavior: SnackBarBehavior.floating,

                  // width: 300,
                  shape: RoundedSuperellipseBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.8),
                shape: BoxShape.circle,
                // borderRadius: BorderRadius.circular(6),
                // Subtle border
              ),
              child: Transform.rotate(
                angle: rotation,
                child: const Icon(
                  Icons.navigation,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ),
        ),
      );
      nextPoint = pos;
    }
    debugPrint("--- [MAP HISTORY] Total Points: ${points.length} ---");
    return {'points': points, 'markers': dots};
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

    // Calculate history data once per build to save battery and CPU
    if (_showHistory && deviceLatLng != null) {
      // We only recalculate if the actual data list (rawPackets) has changed
      // or if we haven't cached anything yet.
      if (_lastPackets != rawPackets || _cachedHistory == null) {
        _cachedHistory = _getHistoryData(rawPackets, deviceLatLng);
        _lastPackets = rawPackets;
      }
    } else {
      _cachedHistory = null;
      _lastPackets = null;
    }

    final historyData = _cachedHistory;

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
                  if (historyData != null) ...[
                    // The Line
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: historyData['points'],
                          strokeWidth: 3.0, // Thinner line for cleaner look
                          color: Colors.blue.withOpacity(0.4),
                          strokeCap: StrokeCap.round,
                        ),
                      ],
                    ),
                    // The Dots (Now perfectly aligned because they share the same historyData)
                    MarkerLayer(markers: historyData['markers']),
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
