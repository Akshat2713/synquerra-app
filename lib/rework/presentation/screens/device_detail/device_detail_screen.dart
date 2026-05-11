import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../data/network/map_tile_config.dart';
import '../../../domain/entities/analytics/analytics_entity.dart';
import '../../../domain/entities/device/device_entity.dart';
import '../../blocs/analytics/analytics_bloc.dart';
import 'widgets/filter_bottom_sheet.dart';
import 'widgets/timeline_slider.dart';
import 'widgets/device_info_panel.dart';
import 'widgets/detail_drawer.dart';

class DeviceDetailScreen extends StatefulWidget {
  final DeviceEntity device;

  const DeviceDetailScreen({super.key, required this.device});

  @override
  State<DeviceDetailScreen> createState() => _DeviceDetailScreenState();
}

class _DeviceDetailScreenState extends State<DeviceDetailScreen> {
  late final MapController _mapController;
  bool _showTimeline = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    context.read<AnalyticsBloc>().add(AnalyticsLoadDefault(widget.device.imei));
    debugPrint('[DeviceDetailScreen] initState → imei: ${widget.device.imei}');
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _openFilterSheet() {
    debugPrint('[DeviceDetailScreen] open filter sheet');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FilterBottomSheet(
        onFilterSelected: (filter) {
          setState(() => _showTimeline = true);
          context.read<AnalyticsBloc>().add(
            AnalyticsFilterChanged(imei: widget.device.imei, filter: filter),
          );
        },
        onCustomSelected: (start, end) {
          setState(() => _showTimeline = true);
          context.read<AnalyticsBloc>().add(
            AnalyticsCustomRangeSelected(
              imei: widget.device.imei,
              startDate: start,
              endDate: end,
            ),
          );
        },
      ),
    );
  }

  void _fitMapToPoints(List<AnalyticsEntity> points) {
    final mappable = points.where((p) => p.hasLocation).toList();
    if (mappable.isEmpty) return;
    if (mappable.length == 1) {
      _mapController.move(
        LatLng(mappable.first.latitude!, mappable.first.longitude!),
        MapTileConfig.defaultZoom,
      );
      return;
    }
    final bounds = LatLngBounds.fromPoints(
      mappable.map((p) => LatLng(p.latitude!, p.longitude!)).toList(),
    );
    _mapController.fitCamera(
      CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(48)),
    );
    debugPrint('[DeviceDetailScreen] fit map to ${mappable.length} points');
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return PopScope(
      canPop: !_showTimeline,
      onPopInvokedWithResult: (didPop, result) async {
        if (_showTimeline) {
          setState(() => _showTimeline = false);
          context.read<AnalyticsBloc>().add(
            AnalyticsFilterChanged(
              imei: widget.device.imei,
              filter: AnalyticsFilter.latest,
            ),
          );
        }
        if (didPop) {
          return;
        }
      },
      child: Scaffold(
        drawer: DetailDrawer(
          userName: widget.device.studentName,
          imei: widget.device.imei,
          device: widget.device,
        ),
        body: BlocConsumer<AnalyticsBloc, AnalyticsState>(
          listenWhen: (prev, curr) =>
              prev is! AnalyticsLoaded ||
              (curr is AnalyticsLoaded && prev.points != curr.points),
          listener: (context, state) {
            if (state is AnalyticsLoaded && state.mappablePoints.isNotEmpty) {
              WidgetsBinding.instance.addPostFrameCallback(
                (_) => _fitMapToPoints(state.points),
              );
            }
          },
          builder: (context, state) {
            final isLoading = state is AnalyticsLoading;
            final loaded = state is AnalyticsLoaded ? state : null;

            final defaultCenter = widget.device.hasLocation
                ? LatLng(
                    double.parse(widget.device.latitude!),
                    double.parse(widget.device.longitude!),
                  )
                : const LatLng(28.6172, 77.2094); // New Delhi fallback

            return Stack(
              children: [
                // ── Full screen map ──────────────────────
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: defaultCenter,
                    initialZoom: MapTileConfig.defaultZoom,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: MapTileConfig.tileUrlTemplate,
                      userAgentPackageName: MapTileConfig.userAgentPackageName,
                    ),

                    // Route polyline
                    if (loaded != null && loaded.mappablePoints.length > 1)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: loaded.mappablePoints
                                .map((p) => LatLng(p.latitude!, p.longitude!))
                                .toList(),
                            color: colors.primary,
                            strokeWidth: 3,
                          ),
                        ],
                      ),

                    // All points markers
                    if (loaded != null)
                      MarkerLayer(
                        markers: loaded.mappablePoints
                            .asMap()
                            .entries
                            .map(
                              (e) => Marker(
                                point: LatLng(
                                  e.value.latitude!,
                                  e.value.longitude!,
                                ),
                                width: e.key == loaded.sliderIndex ? 18 : 12,
                                height: e.key == loaded.sliderIndex ? 18 : 12,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: e.key == loaded.sliderIndex
                                        ? colors.primary
                                        : colors.primary.withValues(alpha: 0.4),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: e.key == loaded.sliderIndex
                                          ? 2
                                          : 1,
                                    ),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                  ],
                ),

                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        _mapIconButton(
                          icon: Icons.menu_rounded,
                          onTap: () => Scaffold.of(context).openDrawer(),
                          colors: colors,
                        ),
                        const SizedBox(width: 8),
                        // Expanded(
                        //   child: _studentNameContainer(
                        //     widget.device.studentName,
                        //     colors,
                        //   ),
                        // ),
                        const SizedBox(
                          width: 48,
                        ), // Gap to prevent overlapping with filter
                      ],
                    ),
                  ),
                ),

                // 4. Top Right: Filter + Horizontal Zoom
                Positioned(
                  top: MediaQuery.of(context).padding.top + 8,
                  right: 12,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _mapIconButton(
                        icon: Icons.filter_list_rounded,
                        onTap: _openFilterSheet,
                        colors: colors,
                        highlighted: _showTimeline,
                      ),
                      const SizedBox(height: 8),
                      Column(
                        children: [
                          _mapIconButton(
                            icon: Icons.add_rounded,
                            onTap: () => _mapController.move(
                              _mapController.camera.center,
                              _mapController.camera.zoom + 1,
                            ),
                            colors: colors,
                          ),
                          const SizedBox(height: 8),
                          _mapIconButton(
                            icon: Icons.remove_rounded,
                            onTap: () => _mapController.move(
                              _mapController.camera.center,
                              _mapController.camera.zoom - 1,
                            ),
                            colors: colors,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // 5. Bottom Right: My Location
                Positioned(
                  right: 12,
                  // Moves up when timeline slider appears
                  bottom: _showTimeline ? 160 : 180,
                  child: _mapIconButton(
                    icon: Icons.my_location_rounded,
                    onTap: () => _mapController.move(defaultCenter, 14),
                    colors: colors,
                  ),
                ),

                // ── Bottom panel ─────────────────────────
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Skeletonizer(
                      enabled: isLoading,
                      child: _showTimeline && loaded != null
                          ? TimelineSlider(
                              points: loaded.mappablePoints,
                              currentIndex: loaded.sliderIndex,
                              onChanged: (i) => context
                                  .read<AnalyticsBloc>()
                                  .add(AnalyticsSliderChanged(i)),
                            )
                          : DeviceInfoPanel(
                              device: widget.device,
                              loaded: loaded,
                            ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _mapIconButton({
    required IconData icon,
    required VoidCallback onTap,
    required ColorScheme colors,
    bool highlighted = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: highlighted ? colors.primary : colors.surface,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8),
          ],
        ),
        child: Icon(
          icon,
          size: 20,
          color: highlighted ? colors.onPrimary : colors.onSurface,
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:latlong2/latlong.dart';
// import 'package:skeletonizer/skeletonizer.dart';
// import '../../../domain/entities/analytics/analytics_entity.dart';
// import '../../../domain/entities/device/device_entity.dart';
// // import '../../../core/di/injection_container.dart';
// import '../../blocs/analytics/analytics_bloc.dart';
// // import '../../app/app_router.dart';
// import 'widgets/filter_bottom_sheet.dart';
// import 'widgets/timeline_slider.dart';
// import 'widgets/device_info_panel.dart';
// import 'widgets/detail_drawer.dart';

// class DeviceDetailScreen extends StatefulWidget {
//   final DeviceEntity device;

//   const DeviceDetailScreen({super.key, required this.device});

//   @override
//   State<DeviceDetailScreen> createState() => _DeviceDetailScreenState();
// }

// class _DeviceDetailScreenState extends State<DeviceDetailScreen> {
//   late final MapController _mapController;
//   bool _showTimeline = false;

//   @override
//   void initState() {
//     super.initState();
//     _mapController = MapController();
//     context.read<AnalyticsBloc>().add(AnalyticsLoadDefault(widget.device.imei));
//   }

//   @override
//   void dispose() {
//     _mapController.dispose();
//     super.dispose();
//   }

//   void _openFilterSheet() {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (_) => FilterBottomSheet(
//         onFilterSelected: (filter) {
//           setState(() => _showTimeline = true);
//           context.read<AnalyticsBloc>().add(
//             AnalyticsFilterChanged(imei: widget.device.imei, filter: filter),
//           );
//         },
//         onCustomSelected: (start, end) {
//           setState(() => _showTimeline = true);
//           context.read<AnalyticsBloc>().add(
//             AnalyticsCustomRangeSelected(
//               imei: widget.device.imei,
//               startDate: start,
//               endDate: end,
//             ),
//           );
//         },
//       ),
//     );
//   }

//   void _fitMapToPoints(List<AnalyticsEntity> points) {
//     final mappable = points.where((p) => p.hasLocation).toList();
//     if (mappable.isEmpty) return;
//     if (mappable.length == 1) {
//       _mapController.move(
//         LatLng(mappable.first.latitude!, mappable.first.longitude!),
//         15,
//       );
//       return;
//     }
//     final bounds = LatLngBounds.fromPoints(
//       mappable.map((p) => LatLng(p.latitude!, p.longitude!)).toList(),
//     );
//     _mapController.fitCamera(
//       CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(48)),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final colors = Theme.of(context).colorScheme;
//     // final user = sl<UserHolder>().user;

//     return Scaffold(
//       drawer: DetailDrawer(
//         userName: widget.device.studentName,
//         imei: widget.device.imei,
//       ),
//       body: BlocConsumer<AnalyticsBloc, AnalyticsState>(
//         listener: (context, state) {
//           if (state is AnalyticsLoaded && state.mappablePoints.isNotEmpty) {
//             WidgetsBinding.instance.addPostFrameCallback(
//               (_) => _fitMapToPoints(state.points),
//             );
//           }
//         },
//         builder: (context, state) {
//           final isLoading = state is AnalyticsLoading;
//           final loaded = state is AnalyticsLoaded ? state : null;

//           // Default map center — device last known or India center
//           final defaultCenter = widget.device.hasLocation
//               ? LatLng(
//                   double.parse(widget.device.latitude!),
//                   double.parse(widget.device.longitude!),
//                 )
//               : const LatLng(28.6172, 77.2094); // New Delhi, India

//           return Stack(
//             children: [
//               // ── Full screen map ──────────────────────
//               FlutterMap(
//                 mapController: _mapController,
//                 options: MapOptions(
//                   initialCenter: defaultCenter,
//                   initialZoom: 14,
//                 ),
//                 children: [
//                   TileLayer(
//                     urlTemplate:
//                         'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
//                     userAgentPackageName: 'com.synquerra.app',
//                   ),

//                   // Route polyline
//                   if (loaded != null && loaded.mappablePoints.length > 1)
//                     PolylineLayer(
//                       polylines: [
//                         Polyline(
//                           points: loaded.mappablePoints
//                               .map((p) => LatLng(p.latitude!, p.longitude!))
//                               .toList(),
//                           color: colors.primary,
//                           strokeWidth: 3,
//                         ),
//                       ],
//                     ),

//                   // All points markers
//                   if (loaded != null)
//                     MarkerLayer(
//                       markers: loaded.mappablePoints
//                           .asMap()
//                           .entries
//                           .map(
//                             (e) => Marker(
//                               point: LatLng(
//                                 e.value.latitude!,
//                                 e.value.longitude!,
//                               ),
//                               width: 12,
//                               height: 12,
//                               child: Container(
//                                 decoration: BoxDecoration(
//                                   color: e.key == loaded.sliderIndex
//                                       ? colors.primary
//                                       : colors.primary.withOpacity(0.4),
//                                   shape: BoxShape.circle,
//                                   border: Border.all(
//                                     color: Colors.white,
//                                     width: e.key == loaded.sliderIndex ? 2 : 1,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           )
//                           .toList(),
//                     ),
//                 ],
//               ),

//               // ── Top bar ──────────────────────────────
//               SafeArea(
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 12,
//                     vertical: 8,
//                   ),
//                   child: Row(
//                     children: [
//                       // Drawer button
//                       _mapIconButton(
//                         icon: Icons.menu_rounded,
//                         onTap: () => Scaffold.of(context).openDrawer(),
//                         colors: colors,
//                       ),
//                       const SizedBox(width: 8),

//                       // Student name chip
//                       Expanded(
//                         child: Container(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 14,
//                             vertical: 8,
//                           ),
//                           decoration: BoxDecoration(
//                             color: colors.surface,
//                             borderRadius: BorderRadius.circular(12),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.black.withOpacity(0.08),
//                                 blurRadius: 8,
//                               ),
//                             ],
//                           ),
//                           child: Text(
//                             widget.device.studentName,
//                             style: TextStyle(
//                               fontWeight: FontWeight.w600,
//                               fontSize: 14,
//                               color: colors.onSurface,
//                             ),
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 8),

//                       // Filter button
//                       _mapIconButton(
//                         icon: Icons.filter_list_rounded,
//                         onTap: _openFilterSheet,
//                         colors: colors,
//                         highlighted: _showTimeline,
//                       ),
//                     ],
//                   ),
//                 ),
//               ),

//               // ── Zoom controls ────────────────────────
//               Positioned(
//                 right: 12,
//                 bottom: _showTimeline ? 280 : 200,
//                 child: Column(
//                   children: [
//                     _mapIconButton(
//                       icon: Icons.add_rounded,
//                       onTap: () => _mapController.move(
//                         _mapController.camera.center,
//                         _mapController.camera.zoom + 1,
//                       ),
//                       colors: colors,
//                     ),
//                     const SizedBox(height: 8),
//                     _mapIconButton(
//                       icon: Icons.remove_rounded,
//                       onTap: () => _mapController.move(
//                         _mapController.camera.center,
//                         _mapController.camera.zoom - 1,
//                       ),
//                       colors: colors,
//                     ),
//                     const SizedBox(height: 8),
//                     _mapIconButton(
//                       icon: Icons.my_location_rounded,
//                       onTap: () => _mapController.move(defaultCenter, 14),
//                       colors: colors,
//                     ),
//                   ],
//                 ),
//               ),

//               // ── Bottom panel ─────────────────────────
//               Positioned(
//                 left: 0,
//                 right: 0,
//                 bottom: 0,
//                 child: Skeletonizer(
//                   enabled: isLoading,
//                   child: _showTimeline && loaded != null
//                       ? TimelineSlider(
//                           points: loaded.mappablePoints,
//                           currentIndex: loaded.sliderIndex,
//                           onChanged: (i) => context.read<AnalyticsBloc>().add(
//                             AnalyticsSliderChanged(i),
//                           ),
//                         )
//                       : DeviceInfoPanel(device: widget.device, loaded: loaded),
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }

//   Widget _mapIconButton({
//     required IconData icon,
//     required VoidCallback onTap,
//     required ColorScheme colors,
//     bool highlighted = false,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         width: 40,
//         height: 40,
//         decoration: BoxDecoration(
//           color: highlighted ? colors.primary : colors.surface,
//           borderRadius: BorderRadius.circular(10),
//           boxShadow: [
//             BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8),
//           ],
//         ),
//         child: Icon(
//           icon,
//           size: 20,
//           color: highlighted ? colors.onPrimary : colors.onSurface,
//         ),
//       ),
//     );
//   }
// }
