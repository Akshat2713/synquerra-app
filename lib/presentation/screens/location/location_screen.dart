// presentation/screens/location/location_screen.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../core/config/map_config.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/utils/app_logger.dart';
import '../../../domain/entities/analytics/analytics_entity.dart';
import '../../../domain/entities/analytics/analytics_filter.dart';
import '../../../domain/entities/device/device_entity.dart';
import '../../blocs/analytics/analytics_bloc.dart';
import '../../blocs/geofence/geofence_bloc.dart';
import '../../blocs/user_location/user_location_bloc.dart';
import '../../themes/app_text_styles.dart';
import '../../themes/colors.dart';
import '../../utils/app_icons.dart';
import '../../widgets/app_overlays.dart';
import '../../widgets/app_surfaces.dart';
import '../../widgets/geofence_polygon_layer.dart';
import 'widgets/address_card.dart';
import 'widgets/history_filter_chips.dart';
import 'widgets/last_updated_badge.dart';
import 'widgets/map_controls_column.dart';
import 'widgets/map_history_markers_layer.dart';
import 'widgets/map_history_polyline_layer.dart';
import 'widgets/map_icon_button.dart';
import 'widgets/map_user_location_layer.dart';
import 'widgets/timeline_slider.dart';
import 'widgets/view_tabs.dart';
import '../../themes/app_tokens.dart';

class LocationScreen extends StatefulWidget {
  final DeviceEntity device;
  const LocationScreen({super.key, required this.device});
  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  // TODO(logic): the cooldown rule, zoom level and fallback center belong in
  // MapConfig / the bloc, not in the widget.
  static const _liveQueryCooldown = Duration(minutes: 5);
  static const _focusZoom = 16.0;
  static const _fallbackCenter = LatLng(28.6172, 77.2094);

  late final MapController _mapController;
  late final UserLocationBloc _userLocationBloc;
  late final TileProvider _tileProvider;
  bool _showTimeline = false;
  bool _isTimelineMinimized = true;

  DateTime? _cooldownUntil;
  Timer? _cooldownTimer;

  bool get _inCooldown =>
      _cooldownUntil != null && DateTime.now().isBefore(_cooldownUntil!);

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _userLocationBloc = sl<UserLocationBloc>();
    _tileProvider = sl<TileProvider>();
    context.read<GeofenceBloc>().add(GeofenceLoad(widget.device.id));
    AppLogger.d('LocationScreen', 'initState → deviceId: ${widget.device.id}');
  }

  LatLng get _defaultCenter => widget.device.hasLocation
      ? LatLng(widget.device.latitude!, widget.device.longitude!)
      : _fallbackCenter;

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    _mapController.dispose();
    _userLocationBloc.close();
    super.dispose();
  }

  void _onViewChanged(bool history) {
    final wasHistory = _showTimeline;
    setState(() {
      _showTimeline = history;
      _isTimelineMinimized = true;
    });

    final bloc = context.read<AnalyticsBloc>();
    if (!wasHistory && history) {
      bloc.add(
        AnalyticsFilterChanged(
          deviceId: widget.device.id,
          filter: AnalyticsFilter.lastHour,
        ),
      );
    } else if (wasHistory && !history) {
      bloc.add(
        AnalyticsFilterChanged(
          deviceId: widget.device.id,
          filter: AnalyticsFilter.latest,
        ),
      );
    }
  }

  void _startCooldown() {
    _cooldownTimer?.cancel();
    setState(() => _cooldownUntil = DateTime.now().add(_liveQueryCooldown));
    _cooldownTimer = Timer(_liveQueryCooldown, () {
      if (mounted) setState(() => _cooldownUntil = null);
    });
  }

  void _onLiveQuery() {
    if (_inCooldown) return;
    if (_showTimeline) {
      setState(() {
        _showTimeline = false;
        _isTimelineMinimized = true;
      });
    }
    context.read<AnalyticsBloc>().add(
      AnalyticsLiveQueryRequested(widget.device.id),
    );
  }

  void _fitMapToPoints(List<AnalyticsEntity> points) {
    final mappable = points.where((p) => p.hasLocation).toList();
    if (mappable.isEmpty) return;
    if (mappable.length == 1 || !_showTimeline) {
      _mapController.move(
        LatLng(mappable.first.latitude!, mappable.first.longitude!),
        MapConfig.defaultZoom,
      );
      return;
    }
    final bounds = LatLngBounds.fromPoints(
      mappable.map((p) => LatLng(p.latitude!, p.longitude!)).toList(),
    );
    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.all(AppSpacing.xl + AppSpacing.md),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isPlayVisible = _showTimeline && _isTimelineMinimized;
    final topInset = MediaQuery.paddingOf(context).top + AppSpacing.sm;

    return PopScope(
      canPop: !_showTimeline,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        // Back from History returns to Latest instead of leaving the screen.
        setState(() {
          _showTimeline = false;
          _isTimelineMinimized = true;
        });
        context.read<AnalyticsBloc>().add(
          AnalyticsFilterChanged(
            deviceId: widget.device.id,
            filter: AnalyticsFilter.latest,
          ),
        );
      },
      child: MultiBlocListener(
        listeners: [
          // Fit the map whenever a new set of points arrives.
          BlocListener<AnalyticsBloc, AnalyticsState>(
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
          ),
          // Live query failed.
          BlocListener<AnalyticsBloc, AnalyticsState>(
            listenWhen: (prev, curr) =>
                curr is AnalyticsLoaded &&
                curr.liveQueryError != null &&
                (prev is! AnalyticsLoaded ||
                    prev.liveQueryError != curr.liveQueryError),
            listener: (context, state) => AppSnackBar.error(
              context,
              (state as AnalyticsLoaded).liveQueryError!,
            ),
          ),
          // History query finished with nothing to draw.
          BlocListener<AnalyticsBloc, AnalyticsState>(
            listenWhen: (prev, curr) =>
                curr is AnalyticsLoaded &&
                !curr.isQuerying &&
                curr.mappablePoints.isEmpty &&
                (prev is! AnalyticsLoaded ||
                    prev.points != curr.points ||
                    prev.activeFilter != curr.activeFilter ||
                    prev.startDate != curr.startDate ||
                    prev.endDate != curr.endDate),
            listener: (context, state) {
              if (!_showTimeline) return; // History mode only
              AppSnackBar.info(
                context,
                'No data found in the selected timeframe.',
              );
            },
          ),
          // Live query finished OK: start the cooldown.
          BlocListener<AnalyticsBloc, AnalyticsState>(
            listenWhen: (prev, curr) =>
                prev is AnalyticsLoaded &&
                prev.isQuerying &&
                curr is AnalyticsLoaded &&
                !curr.isQuerying &&
                curr.liveQueryError == null,
            listener: (context, state) => _startCooldown(),
          ),
          BlocListener<UserLocationBloc, UserLocationState>(
            bloc: _userLocationBloc,
            listener: (context, state) {
              if (state is UserLocationLoaded) {
                _mapController.move(state.position, _focusZoom);
              }
              if (state is UserLocationError) {
                AppSnackBar.error(context, state.message);
              }
            },
          ),
        ],
        child: Stack(
          children: [
            // MAP LAYER
            RepaintBoundary(
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _defaultCenter,
                  initialZoom: MapConfig.defaultZoom,
                ),
                children: [
                  TileLayer(
                    urlTemplate: MapConfig.tileUrlTemplate,
                    userAgentPackageName: MapConfig.userAgentPackageName,
                    tileProvider: _tileProvider,
                  ),
                  GeofencePolygonLayer(onGeofenceTap: (_) {}),
                  const MapHistoryPolylineLayer(),
                  const MapHistoryMarkersLayer(),
                  MapUserLocationLayer(userLocationBloc: _userLocationBloc),
                ],
              ),
            ),

            // TOP LEFT: VIEW TABS + ADDRESS CARD (stacked, so no magic offset)
            Positioned(
              top: topInset,
              left: AppSpacing.smd,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: AppSpacing.sm,
                children: [
                  ViewTabs(isHistory: _showTimeline, onChanged: _onViewChanged),
                  BlocBuilder<AnalyticsBloc, AnalyticsState>(
                    buildWhen: (prev, curr) {
                      final prevPoint = prev is AnalyticsLoaded
                          ? prev.currentPoint
                          : null;
                      final currPoint = curr is AnalyticsLoaded
                          ? curr.currentPoint
                          : null;
                      return prevPoint != currPoint ||
                          prev.runtimeType != curr.runtimeType;
                    },
                    builder: (context, state) {
                      final loaded = state is AnalyticsLoaded ? state : null;
                      return AddressCard(
                        point: loaded?.currentPoint,
                        isLoading: state is AnalyticsLoading,
                      );
                    },
                  ),
                ],
              ),
            ),

            // TOP RIGHT: LAST UPDATED + MAP CONTROLS (zoom slider + compass)
            Positioned(
              top: topInset,
              right: AppSpacing.smd,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                spacing: AppSpacing.sm,
                children: [
                  BlocBuilder<AnalyticsBloc, AnalyticsState>(
                    buildWhen: (prev, curr) {
                      final p = prev is AnalyticsLoaded
                          ? prev.currentPoint?.deviceTimestamp
                          : null;
                      final c = curr is AnalyticsLoaded
                          ? curr.currentPoint?.deviceTimestamp
                          : null;
                      return p != c || prev.runtimeType != curr.runtimeType;
                    },
                    builder: (context, state) {
                      final loaded = state is AnalyticsLoaded ? state : null;
                      return LastUpdatedBadge(
                        timestamp: loaded?.currentPoint?.deviceTimestamp,
                      );
                    },
                  ),
                  MapControlsColumn(mapController: _mapController),
                ],
              ),
            ),

            // BOTTOM LEFT: LIVE QUERY BUTTON (Latest mode only)
            if (!_showTimeline)
              Positioned(
                bottom: AppSpacing.lg,
                left: AppSpacing.smd,
                child: BlocSelector<AnalyticsBloc, AnalyticsState, bool>(
                  selector: (s) => s is AnalyticsLoaded && s.isQuerying,
                  builder: (context, isQuerying) {
                    return MapIconButton(
                      icon: AppIcons.liveQuery,
                      tooltip: 'Request live location',
                      onTap: (_inCooldown || isQuerying) ? null : _onLiveQuery,
                      child: isQuerying
                          ? const SizedBox(
                              width: AppSize.iconSm,
                              height: AppSize.iconSm,
                              child: CircularProgressIndicator(
                                strokeWidth: AppSize.stroke,
                              ),
                            )
                          : null,
                    );
                  },
                ),
              ),

            // BOTTOM RIGHT: RECENTER BUTTONS (lifted above the Play overlay)
            Positioned(
              bottom: isPlayVisible
                  ? AppSize.mapPlayBottom + AppSize.tapTarget + AppSpacing.sm
                  : AppSpacing.lg,
              right: AppSpacing.smd,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                spacing: AppSpacing.sm,
                children: [
                  MapIconButton(
                    icon: AppIcons.recenterDevice,
                    tooltip: 'Center on device',
                    onTap: () {
                      AppLogger.d(
                        'LocationScreen',
                        'recenter target=$_defaultCenter, camera before=${_mapController.camera.center}',
                      );
                      _mapController.move(_defaultCenter, _focusZoom);
                    },
                  ),
                  // User GPS button is hidden while the Play overlay is shown.
                  if (!isPlayVisible)
                    BlocBuilder<UserLocationBloc, UserLocationState>(
                      bloc: _userLocationBloc,
                      builder: (context, state) {
                        final isLoading = state is UserLocationLoading;
                        return MapIconButton(
                          icon: isLoading
                              ? AppIcons.userLoading
                              : AppIcons.recenterUser,
                          tooltip: 'Show my location',
                          onTap: isLoading
                              ? null
                              : () =>
                                    _userLocationBloc.add(FetchUserLocation()),
                        );
                      },
                    ),
                ],
              ),
            ),

            // BOTTOM PANEL: TIMELINE SLIDER + HISTORY CHIPS
            Positioned.fill(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: BlocBuilder<AnalyticsBloc, AnalyticsState>(
                  buildWhen: (prev, curr) {
                    if (prev is AnalyticsLoaded && curr is AnalyticsLoaded) {
                      return prev.sliderIndex != curr.sliderIndex ||
                          prev.points != curr.points;
                    }
                    return prev.runtimeType != curr.runtimeType;
                  },
                  builder: (context, state) {
                    if (!_showTimeline) return const SizedBox.shrink();
                    final isLoading = state is AnalyticsLoading;
                    final loaded = state is AnalyticsLoaded ? state : null;
                    final activeFilter =
                        loaded?.activeFilter ?? AnalyticsFilter.lastHour;
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!_isTimelineMinimized)
                          Skeletonizer(
                            enabled: isLoading,
                            child: TimelineSlider(
                              points: loaded?.mappablePoints ?? const [],
                              currentIndex: loaded?.sliderIndex ?? 0,
                              onChanged: (i) => context
                                  .read<AnalyticsBloc>()
                                  .add(AnalyticsSliderChanged(i)),
                              onMinimize: () =>
                                  setState(() => _isTimelineMinimized = true),
                            ),
                          ),
                        HistoryFilterChips(
                          activeFilter: activeFilter,
                          isLoading: isLoading,
                          onFilterSelected: (f) =>
                              context.read<AnalyticsBloc>().add(
                                AnalyticsFilterChanged(
                                  deviceId: widget.device.id,
                                  filter: f,
                                ),
                              ),
                          onCustomSelected: (start, end) =>
                              context.read<AnalyticsBloc>().add(
                                AnalyticsCustomRangeSelected(
                                  deviceId: widget.device.id,
                                  startDate: start,
                                  endDate: end,
                                ),
                              ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),

            // PLAY OVERLAY (History mode, timeline minimized)
            if (isPlayVisible)
              Positioned(
                bottom: AppSize.mapPlayBottom,
                right: AppSpacing.smd,
                child: _PlayOverlay(
                  onTap: () => setState(() => _isTimelineMinimized = false),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Floating "Play" pill that expands the timeline panel.
class _PlayOverlay extends StatelessWidget {
  final VoidCallback onTap;
  const _PlayOverlay({required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Material + InkWell sit INSIDE the card so the ripple is visible.
    return Semantics(
      button: true,
      label: 'Open timeline playback',
      child: AppCard(
        padding: EdgeInsets.zero,
        child: Material(
          type: MaterialType.transparency,
          borderRadius: AppRadius.lgAll,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {
              HapticFeedback.selectionClick();
              onTap();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.smd,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: AppSpacing.xs,
                children: [
                  Icon(
                    AppIcons.play,
                    size: AppSize.iconLg,
                    color: AppColors.primary(context),
                  ),
                  Text(
                    'Play',
                    style: AppTextStyles.metaWithColor(
                      context,
                      color: AppColors.textPrimary(context),
                    ).copyWith(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
