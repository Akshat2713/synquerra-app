// lib/presentation/screens/home/map_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../business/blocs/auth_bloc/auth_bloc.dart';
import '../../../business/blocs/device_bloc/device_bloc.dart';
import '../../../business/blocs/navigation_bloc/navigation_bloc.dart';
import '../../widgets/core/app_button.dart';
import '../../widgets/core/app_loading.dart';
import '../../widgets/core/app_empty.dart';
import '../../widgets/core/app_error.dart';
import '../../widgets/map/map_search_bar.dart';
import '../../widgets/map/map_zoom_controls.dart';
import '../../widgets/feedback/custom_snackbar.dart';
import '../profile/my_profile_drawer.dart';
import 'device_details_sheet.dart';
import '../../../di/injection_container.dart' as di;

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final MapController _mapController = MapController();
  double _currentZoom = 16;
  bool _showHistory = false;

  @override
  void initState() {
    super.initState();
    _loadDeviceData();
  }

  void _loadDeviceData() {
    final deviceState = context.read<DeviceBloc>().state;

    // Only fetch if no data exists
    if (deviceState is DeviceInitial || deviceState is DeviceError) {
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated) {
        context.read<DeviceBloc>().add(
          DeviceDataRequested(imei: authState.user.imei),
        );
      }
    } else {
      debugPrint('✅ Data already loaded, skipping fetch');
    }
  }

  void _handleRetry() {
    _loadDeviceData();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: theme.scaffoldBackgroundColor,
      endDrawer: const MyProfileDrawer(),
      body: BlocBuilder<DeviceBloc, DeviceState>(
        builder: (context, state) {
          // Loading State
          if (state is DeviceLoading) {
            return const AppLoading(message: 'Loading device data...', fullScreen: true);
          }

          // Error State
          if (state is DeviceError) {
            return AppError(
              message: state.message,
              onRetry: _handleRetry,
              buttonText: "Retry",
            );
          }

          // No Data State
          if (state is DeviceLoaded && state.latestTelemetry == null) {
            return AppEmpty(
              title: "No device data",
              subtitle: "Waiting for device to send location...",
              icon: Icons.sensors_off_rounded,
              onRefresh: _handleRetry,
              buttonText: "Refresh",
            );
          }

          // Data Loaded State
          if (state is DeviceLoaded && state.latestTelemetry != null) {
            final deviceLatLng = LatLng(
              state.latestTelemetry!.latitude!,
              state.latestTelemetry!.longitude!,
            );

            return Stack(
              children: [
                // Map Layer
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: deviceLatLng,
                    initialZoom: _currentZoom,
                    onPositionChanged: (pos, gesture) {
                      if (pos.zoom != null && pos.zoom != _currentZoom) {
                        setState(() => _currentZoom = pos.zoom!);
                      }
                    },
                  ),
                  children: [
                    // Tile Layer - OpenStreetMap (free, no API key)
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.synquerra.app',
                      subdomains: ['a', 'b', 'c'],
                    ),
                    
                    // History Polyline Layer
                    if (_showHistory && state.historyPoints.isNotEmpty)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: state.historyPoints,
                            strokeWidth: 3.0,
                            color: Colors.blue.withValues(alpha: 0.4),
                          ),
                        ],
                      ),
                    
                    // Device Marker Layer
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: deviceLatLng,
                          width: 80,
                          height: 80,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.green.withValues(alpha: 0.3),
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
                  ],
                ),

                // Search Bar (Custom widget - keep as is)
                MapSearchBar(
                  onSearchSelected: (imei) {
                    // TODO: Handle device search
                    debugPrint('Search selected: $imei');
                  },
                ),

                // Zoom Controls (Custom widget - keep as is)
                MapZoomControls(
                  onZoomIn: () {
                    setState(() {
                      _currentZoom++;
                      _mapController.move(
                        _mapController.camera.center,
                        _currentZoom,
                      );
                    });
                  },
                  onZoomOut: () {
                    setState(() {
                      _currentZoom--;
                      _mapController.move(
                        _mapController.camera.center,
                        _currentZoom,
                      );
                    });
                  },
                ),

                // Device Details Sheet
                DeviceDetailsSheet(
                  showingSearch: false,
                  isHistoryVisible: _showHistory,
                  onToggleHistory: () {
                    setState(() => _showHistory = !_showHistory);
                    if (!_showHistory) {
                      context.read<DeviceBloc>().add(
                        DeviceHistoryRequested(
                          imei: state.latestTelemetry!.imei,
                        ),
                      );
                    }
                  },
                ),
              ],
            );
          }

          // Fallback loading
          return const AppLoading();
        },
      ),
    );
  }
}