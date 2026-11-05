import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';

import '../../../data/datasources/graphql/mode_conditions_query.dart';
import '../../../domain/entities/geofence/geofence_entity.dart';
import '../../../domain/entities/geofence/geofence_slot.dart';
import '../../../domain/entities/geofence_mode/mode_condition_entity.dart';
import '../../app/app_router.dart';
import '../../blocs/geofence/geofence_bloc.dart';
import '../../blocs/mode_condition/mode_condition_bloc.dart';
import '../../themes/app_tokens.dart';
import '../../themes/app_text_styles.dart';
import '../../themes/colors.dart';
import '../../utils/app_icons.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_empty_state.dart';
import '../../widgets/app_motion_widgets.dart';
import '../../widgets/app_overlays.dart';
import '../../widgets/app_surfaces.dart';
import '../../widgets/async_state_view.dart';
import 'geofence_list_page_widgets/device_geofence_slots.dart';
import 'geofence_list_page_widgets/geofence_list_tile.dart';
import 'geofence_list_page_widgets/select_cloud_geofence_dialog.dart';
import 'widgets/configure_trigger_mode_dialog.dart';

class GeofenceListPage extends StatefulWidget {
  final String deviceId;
  final LatLng initialCenter;

  const GeofenceListPage({
    super.key,
    required this.deviceId,
    required this.initialCenter,
  });

  @override
  State<GeofenceListPage> createState() => _GeofenceListPageState();
}

class _GeofenceListPageState extends State<GeofenceListPage> {
  final _searchController = TextEditingController();
  String _query = '';

  // TODO(logic): move cached lists to bloc state (keep last loaded data
  // while loading / operating).
  List<ModeConditionEntity> _conditions = const [];
  List<GeofenceEntity> _geofences = const [];

  @override
  void initState() {
    super.initState();
    context.read<GeofenceBloc>().add(GeofenceLoad(widget.deviceId));
    context.read<ModeConditionBloc>().add(ModeConditionLoad(widget.deviceId));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // TODO(logic): move search filtering to bloc/utils.
  List<GeofenceEntity> _filtered(List<GeofenceEntity> all) {
    if (_query.isEmpty) return all;
    final q = _query.toLowerCase();
    return all.where((g) => g.geofenceName.toLowerCase().contains(q)).toList();
  }

  // TODO(logic): move condition lookup (synced -> device_geofence,
  // otherwise -> geofence) to bloc/utils.
  ModeConditionEntity? _conditionFor(GeofenceEntity g) {
    final type = g.isSyncToDevice
        ? ModeConditionType.deviceGeofence
        : ModeConditionType.geofence;

    for (final c in _conditions) {
      if (c.conditionType == type && c.geofenceId == g.id) return c;
    }
    return null;
  }

  void _openModeDialog(GeofenceEntity geofence) {
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<ModeConditionBloc>(),
        child: ConfigureTriggerModeDialog(
          deviceId: widget.deviceId,
          geofence: geofence,
          existing: _conditionFor(geofence),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, GeofenceEntity geofence) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Geofence'),
        content: Text(
          'Are you sure you want to delete "${geofence.geofenceName}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          AppButton(
            label: 'Delete',
            fullWidth: false,
            backgroundColor: AppColors.danger,
            foregroundColor: AppColors.onDanger,
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<GeofenceBloc>().add(
                GeofenceDelete(deviceId: widget.deviceId, id: geofence.id),
              );
            },
          ),
        ],
      ),
    );
  }

  /// Cross button: confirm, then unassign by slot number only.
  void _confirmUnassign(GeofenceSlot slot) {
    final geofence = slot.geofence;
    if (geofence == null) return;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Unassign Geofence'),
        content: Text(
          'Remove "${geofence.geofenceName}" from slot ${slot.index}? '
          'It will go back to cloud geofences.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          AppButton(
            label: 'Unassign',
            fullWidth: false,
            backgroundColor: AppColors.danger,
            foregroundColor: AppColors.onDanger,
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<GeofenceBloc>().add(
                GeofenceUnassign(
                  deviceId: widget.deviceId,
                  geofenceId: geofence.id,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// Plus button on an empty slot: pick a cloud geofence, then assign it.
  Future<void> _assignToSlot(
    GeofenceSlot slot,
    List<GeofenceEntity> cloudGeofences,
  ) async {
    final picked = await showSelectCloudGeofenceDialog(
      context,
      cloudGeofences: cloudGeofences,
      slotNumber: '${slot.index}',
    );

    if (picked == null || !mounted) return;

    context.read<GeofenceBloc>().add(
      GeofenceAssign(
        deviceId: widget.deviceId,
        geofenceId: picked.id,
        geofenceNumber: slot.number,
      ),
    );
  }

  void _openAddPage({GeofenceEntity? existing}) {
    AppRouter.pushAddGeofence(
      context,
      bloc: context.read<GeofenceBloc>(),
      deviceId: widget.deviceId,
      initialCenter: widget.initialCenter,
      existing: existing,
    );
  }

  void _onTileTab(GeofenceEntity geofence) {
    if (geofence.coordinates.isEmpty) return;

    Navigator.pushNamed(
      context,
      AppRoutes.geofencePreview,
      arguments: GeofencePreviewArgs(geofence: geofence),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ModeConditionBloc, ModeConditionState>(
      listener: (context, state) {
        if (state is ModeConditionLoaded) {
          setState(() => _conditions = state.conditions);
        } else if (state is ModeConditionCreated) {
          AppSnackBar.success(context, 'Trigger mode saved.');
        } else if (state is ModeConditionUpdated) {
          AppSnackBar.success(context, 'Trigger mode updated.');
        } else if (state is ModeConditionDeleted) {
          AppSnackBar.success(context, 'Trigger mode removed.');
        } else if (state is ModeConditionOperationError) {
          AppSnackBar.error(context, state.message);
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Geofences')),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _openAddPage,
          icon: Icon(AppIcons.add),
          label: const Text('New Geofence'),
        ),
        body: BlocConsumer<GeofenceBloc, GeofenceState>(
          listener: (context, state) {
            if (state is GeofenceLoaded) {
              setState(() => _geofences = state.geofences);
            } else if (state is GeofenceDeleted) {
              AppSnackBar.success(context, 'Geofence deleted.');
            } else if (state is GeofenceAssigned) {
              AppSnackBar.success(context, 'Geofence assigned to device.');
            } else if (state is GeofenceUnassigned) {
              AppSnackBar.success(context, 'Geofence unassigned from device.');
            } else if (state is GeofenceOperationError) {
              AppSnackBar.error(context, state.message);
            }
          },
          builder: (context, state) {
            final isLoading = state is GeofenceLoading;
            final errorMessage = state is GeofenceError ? state.message : null;
            final geofences = state is GeofenceLoaded
                ? state.geofences
                : _geofences;

            // Device section is a fixed 3-slot layout built from ALL
            // geofences (search does not hide slots).
            final slots = GeofenceSlot.fromGeofences(geofences);
            final used = slots.where((s) => !s.isEmpty).length;

            final cloudAll = geofences.where((g) => !g.isSyncToDevice).toList();
            final cloudFiltered = _filtered(cloudAll);

            return AsyncStateView(
              isLoading: isLoading,
              errorMessage: errorMessage,
              onRetry: () {
                context.read<GeofenceBloc>().add(GeofenceLoad(widget.deviceId));
              },
              builder: () => Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      AppSpacing.md,
                      AppSpacing.md,
                      AppSpacing.sm,
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (v) => setState(() => _query = v),
                      decoration: InputDecoration(
                        hintText: 'Search cloud geofences...',
                        prefixIcon: Icon(AppIcons.search),
                        suffixIcon: _query.isNotEmpty
                            ? IconButton(
                                tooltip: 'Clear search',
                                icon: Icon(AppIcons.close),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _query = '');
                                },
                              )
                            : null,
                      ),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md,
                        AppSpacing.sm,
                        AppSpacing.md,
                        AppSize.tapTarget + AppSpacing.xl,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        spacing: AppSpacing.lg,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            spacing: AppSpacing.smd,
                            children: [
                              _SectionHeader(
                                title: 'Important',
                                count: '$used/${GeofenceSlot.totalSlots}',
                                dotColor: AppColors.success,
                                background: AppColors.successContainer,
                              ),
                              DeviceGeofenceSlots(
                                slots: slots,
                                modeNameFor: (g) =>
                                    _conditionFor(g)?.mode?.name,
                                onAddToSlot: (slot) =>
                                    _assignToSlot(slot, cloudAll),
                                onTap: _onTileTab,
                                onEdit: (g) => _openAddPage(existing: g),
                                onDelete: (g) => _confirmDelete(context, g),
                                onMode: _openModeDialog,
                                onUnassign: _confirmUnassign,
                              ),
                            ],
                          ).entrance(context, index: 0),
                          _buildCloudSection(
                            context,
                            items: cloudFiltered,
                            hasAnyCloud: cloudAll.isNotEmpty,
                          ).entrance(context, index: 1),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCloudSection(
    BuildContext context, {
    required List<GeofenceEntity> items,
    required bool hasAnyCloud,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSpacing.smd,
      children: [
        _SectionHeader(
          title: 'General',
          count: '${items.length}',
          dotColor: AppColors.info,
          background: AppColors.infoContainer,
        ),
        if (items.isEmpty)
          AppEmptyState(
            icon: hasAnyCloud ? AppIcons.search : AppIcons.geofence,
            title: hasAnyCloud ? 'No matches' : 'No cloud geofences yet',
            message: hasAnyCloud
                ? 'No geofences match your search.'
                : 'Tap New Geofence to create one.',
          ),
        for (final g in items)
          GeofenceListTile(
            geofence: g,
            modeName: _conditionFor(g)?.mode?.name,
            onTap: () => _onTileTab(g),
            onEdit: () => _openAddPage(existing: g),
            onDelete: () => _confirmDelete(context, g),
            onMode: () => _openModeDialog(g),
          ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String count;
  final Color dotColor;
  final Color background;

  const _SectionHeader({
    required this.title,
    required this.count,
    required this.dotColor,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: AppSpacing.sm,
      children: [
        Text(title, style: AppTextStyles.sectionWithColor(context)),
        InfoPill(
          label: count,
          dotColor: dotColor,
          background: background,
          foreground: AppColors.textPrimary(context),
        ),
      ],
    );
  }
}
