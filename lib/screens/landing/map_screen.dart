import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map_compass/flutter_map_compass.dart';
import 'package:synquerra/core/services/update_device_service.dart';
import 'package:synquerra/providers/user_provider.dart';
import 'package:synquerra/providers/device_provider.dart';
import 'package:synquerra/providers/searched_device_provider.dart';
import 'package:synquerra/screens/landing/device_details_sheet.dart';
import 'package:synquerra/widgets/custom_snackbar.dart';
// import 'package:synquerra/widgets/history_dot.dart';
import 'package:synquerra/theme/colors.dart';
// import 'package:synquerra/widgets/common/custom_snackbar.dart'; // Using your custom snackbar
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

  @override
  void initState() {
    super.initState();
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
    final deviceProv = context.read<DeviceProvider>();
    final updateService = context.read<UpdateDeviceService>();

    if (user?.imei == null) return;

    setState(() => _isRefreshingManually = true);

    try {
      // 1. Send command to device
      final response = await updateService.queryNormal(
        imei: user!.imei,
        params: {},
      );

      if (response.status == 'SENT') {
        // 2. Show feedback that command was sent
        CustomSnackbar.show(
          context,
          message: "Updating...",
          type: SnackbarType.info,
        );

        // 3. Store current state for comparison
        final initialPacketCount = deviceProv.allPackets.length;
        final initialTimestamp = deviceProv.lastDataTimestamp;

        // 4. Implement retry with exponential backoff
        bool dataUpdated = false;
        int attempts = 0;
        const maxAttempts = 5;

        while (!dataUpdated && attempts < maxAttempts) {
          // Wait with exponential backoff
          final waitTime = Duration(seconds: 2 * (1 << attempts));
          await Future.delayed(waitTime);

          // Force refresh the device data
          await deviceProv.refreshMyDevice(user.imei, forceRefresh: true);

          // Check if we got new data using timestamp comparison
          if (deviceProv.lastDataTimestamp != null &&
              initialTimestamp != null) {
            if (deviceProv.lastDataTimestamp!.isAfter(initialTimestamp)) {
              dataUpdated = true;
            }
          } else if (deviceProv.allPackets.length > initialPacketCount) {
            // Fallback to packet count comparison
            dataUpdated = true;
          }

          if (dataUpdated) {
            CustomSnackbar.show(
              context,
              message: "New data received!",
              type: SnackbarType.success,
            );
          } else {
            attempts++;
            if (attempts < maxAttempts) {
              CustomSnackbar.show(
                context,
                message:
                    "Waiting for device response... (Attempt $attempts/$maxAttempts)",
                type: SnackbarType.info,
              );
            }
          }
        }

        if (!dataUpdated && mounted) {
          CustomSnackbar.show(
            context,
            message: "Device didn't respond. Please try again later.",
            type: SnackbarType.warning,
          );
        }
      }
    } catch (e) {
      debugPrint("Refresh sequence failed: $e");
      if (mounted) {
        CustomSnackbar.show(
          context,
          message: "Refresh failed",
          type: SnackbarType.error,
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

  void _showTimeSnippet(BuildContext context, String rawTime) {
    final packetTime = DateTime.parse(rawTime).toLocal();
    final timeLabel =
        "${packetTime.hour.toString().padLeft(2, '0')}:${packetTime.minute.toString().padLeft(2, '0')} on ${packetTime.day}/${packetTime.month}/${packetTime.year}";

    // Using your custom snackbar
    CustomSnackbar.show(
      context,
      message: "Device was here at $timeLabel",
      type: SnackbarType.info,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final myProv = context.watch<DeviceProvider>();
    final searchProv = context.watch<SearchedDeviceProvider>();

    if (myProv.errorMessage != null && !myProv.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          CustomSnackbar.show(
            context,
            message: myProv.errorMessage!,
            type: SnackbarType.error,
          );
        }
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
        ? LatLng(activeTelemetry!.latitude!, activeTelemetry.longitude!)
        : null;

    final rawPackets = (showingSearch
        ? searchProv.allPackets
        : myProv.allPackets);

    final LatLng initialMapCenter =
        deviceLatLng ?? const LatLng(28.3702, 77.1236);

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
          backgroundColor: theme.scaffoldBackgroundColor,
          endDrawer: const MyProfileDrawer(),
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: FloatingActionButton(
              backgroundColor: colorScheme.primary,
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
                  : const Icon(Icons.refresh_rounded, color: Colors.white),
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          body: Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: initialMapCenter,
                  initialZoom: _currentZoom,
                  onPositionChanged: (pos, gesture) {
                    if (pos.zoom != null && pos.zoom != _currentZoom) {
                      setState(() => _currentZoom = pos.zoom!);
                    }
                    if (gesture) FocusScope.of(context).unfocus();
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://api.maptiler.com/maps/openstreetmap/{z}/{x}/{y}.png?key=uOv6PI7AYa13sqD3rQbo',
                    userAgentPackageName: 'com.synquerra.app',
                  ),

                  // History Layer
                  if (_showHistory && myProv.historyPoints.isNotEmpty) ...[
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: myProv.historyPoints,
                          strokeWidth: 3.0,
                          color: Colors.blue.withValues(alpha: 0.4),
                        ),
                      ],
                    ),

                    MarkerLayer(
                      markers: List.generate(myProv.historyBearings.length, (
                        index,
                      ) {
                        final point = myProv.historyPoints[index + 1];
                        final bearing = myProv.historyBearings[index];

                        return Marker(
                          point: point,
                          width: 28,
                          height: 28,
                          child: GestureDetector(
                            onTap: () => _showTimeSnippet(
                              context,
                              myProv.historyTimestamps[index],
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.15),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Transform.rotate(
                                angle: bearing,
                                child: Icon(
                                  Icons.navigation,
                                  color: Colors.blue.shade700,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],

                  // Live Device Marker
                  if (activeTelemetry != null)
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: deviceLatLng!,
                          width: 80,
                          height: 80,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.safeGreen.withValues(
                                    alpha: 0.3,
                                  ),
                                  blurRadius: 12,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.boy_rounded,
                              color: Colors.green,
                              size: 50,
                            ),
                          ),
                        ),
                      ],
                    ),

                  // Compass
                  MapCompass(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colorScheme.surface.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.explore_rounded,
                        size: 28,
                        color: colorScheme.primary,
                      ),
                    ),
                    alignment: Alignment.topRight,
                    padding: const EdgeInsets.only(top: 110, right: 10),
                  ),
                ],
              ),

              // Modern Search Bar
              Positioned(
                top: MediaQuery.of(context).padding.top + 10,
                left: 10,
                right: 10,
                child: Material(
                  elevation: 8,
                  shadowColor: Colors.black.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: colorScheme.outlineVariant.withValues(
                          alpha: 0.3,
                        ),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.search_rounded,
                          color: colorScheme.primary,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Autocomplete<String>(
                            key: ValueKey(_hasLoadedImeis),
                            optionsBuilder: (textValue) async {
                              if (!_hasLoadedImeis) {
                                _loadImeis();
                                return const Iterable<String>.empty();
                              }
                              if (textValue.text.isEmpty)
                                return _allImeis.take(5);
                              return _allImeis
                                  .where(
                                    (imei) => imei.contains(textValue.text),
                                  )
                                  .take(5);
                            },
                            onSelected: _handleSearchSelection,
                            fieldViewBuilder: (ctx, ctrl, node, onSub) {
                              return TextField(
                                controller: ctrl,
                                focusNode: node,
                                textInputAction: TextInputAction.search,
                                onSubmitted: _handleSearchSelection,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                                decoration: InputDecoration(
                                  hintText: "Search device by IMEI",
                                  hintStyle: TextStyle(
                                    fontSize: 16,
                                    color: colorScheme.onSurfaceVariant
                                        .withValues(alpha: 0.6),
                                  ),
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (_isLoadingImeis)
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: colorScheme.primary,
                              ),
                            ),
                          ),
                        Container(
                          height: 32,
                          width: 1,
                          color: colorScheme.outlineVariant.withValues(
                            alpha: 0.5,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: Icon(
                            Icons.menu_rounded,
                            color: colorScheme.primary,
                          ),
                          onPressed: () =>
                              _scaffoldKey.currentState?.openEndDrawer(),
                          style: IconButton.styleFrom(
                            backgroundColor: colorScheme.primary.withValues(
                              alpha: 0.1,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Modern Zoom Controls
              Positioned(
                top: MediaQuery.of(context).padding.top + 130,
                right: 10,
                child: Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surface.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 8,
                        color: Colors.black.withValues(alpha: 0.15),
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.add_rounded),
                        onPressed: () {
                          setState(() {
                            _currentZoom++;
                            _mapController.move(
                              _mapController.camera.center,
                              _currentZoom,
                            );
                          });
                        },
                        iconSize: 28,
                        color: colorScheme.primary,
                      ),
                      Container(
                        height: 1,
                        width: 30,
                        color: colorScheme.outlineVariant.withValues(
                          alpha: 0.5,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.remove_rounded),
                        onPressed: () {
                          setState(() {
                            _currentZoom--;
                            _mapController.move(
                              _mapController.camera.center,
                              _currentZoom,
                            );
                          });
                        },
                        iconSize: 28,
                        color: colorScheme.primary,
                      ),
                    ],
                  ),
                ),
              ),

              // History Hint Badge
              if (_showHistory && myProv.historyPoints.isNotEmpty)
                Positioned(
                  top: MediaQuery.of(context).padding.top + 200,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.history_rounded,
                          size: 18,
                          color: Colors.blue.shade700,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "24h history",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Device Details Sheet
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
                  color: Colors.black.withValues(alpha: 0.3),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(
                            width: 40,
                            height: 40,
                            child: CircularProgressIndicator(strokeWidth: 3),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            showingSearch
                                ? "Loading device data..."
                                : "Updating tracking data...",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // No Data Placeholder
              if (!isLoadingData && deviceLatLng == null)
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    margin: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: colorScheme.surface.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.sensors_off_rounded,
                          size: 64,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "No device data available",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Pull to refresh or check device connection",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _handleManualRefresh,
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text(
                            "Refresh Now",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
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
}
