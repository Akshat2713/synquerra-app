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
import '../../themes/colors.dart';
import '../../widgets/async_state_view.dart';
import 'geofence_list_page_widgets/device_geofence_slots.dart';
import 'geofence_list_page_widgets/geofence_list_tile.dart';
import 'geofence_list_page_widgets/select_cloud_geofence_dialog.dart';
import 'widgets/configure_trigger_mode_dialog.dart';
import 'package:synquerra/presentation/themes/app_tokens.dart';

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

  // Last loaded conditions, kept here so tiles don't lose their mode while
  // the bloc is in a loading/operation state.
  List<ModeConditionEntity> _conditions = const [];

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

  List<GeofenceEntity> _filtered(List<GeofenceEntity> all) {
    if (_query.isEmpty) return all;

    return all
        .where(
          (g) => g.geofenceName.toLowerCase().contains(_query.toLowerCase()),
        )
        .toList();
  }

  /// Finds the mode condition attached to this geofence.
  /// Synced to device -> device_geofence, otherwise -> geofence.
  ModeConditionEntity? _conditionFor(GeofenceEntity g) {
    final type = g.isSyncToDevice
        ? ModeConditionType.deviceGeofence
        : ModeConditionType.geofence;

    for (final c in _conditions) {
      if (c.conditionType == type && c.geofenceId == g.id) {
        return c;
      }
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
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () {
              Navigator.pop(dialogContext);

              context.read<GeofenceBloc>().add(
                GeofenceDelete(deviceId: widget.deviceId, id: geofence.id),
              );
            },
            child: const Text('Delete'),
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
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () {
              Navigator.pop(dialogContext);

              context.read<GeofenceBloc>().add(
                GeofenceUnassign(
                  deviceId: widget.deviceId,
                  geofenceNumber: slot.number,
                ),
              );
            },
            child: const Text('Unassign'),
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

  void _snack(String message, {Color? color}) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ModeConditionBloc, ModeConditionState>(
      listener: (context, state) {
        if (state is ModeConditionLoaded) {
          setState(() => _conditions = state.conditions);
        } else if (state is ModeConditionCreated) {
          _snack('Trigger mode saved.');
        } else if (state is ModeConditionUpdated) {
          _snack('Trigger mode updated.');
        } else if (state is ModeConditionDeleted) {
          _snack('Trigger mode removed.');
        } else if (state is ModeConditionOperationError) {
          _snack(state.message, color: AppColors.danger);
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Geofences')),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _openAddPage,
          icon: const Icon(Icons.add_rounded),
          label: const Text('New Geofence'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          elevation: 6,
        ),
        body: BlocConsumer<GeofenceBloc, GeofenceState>(
          listener: (context, state) {
            if (state is GeofenceDeleted) {
              _snack('Geofence deleted.');
            } else if (state is GeofenceAssigned) {
              _snack('Geofence assigned to device.');
            } else if (state is GeofenceUnassigned) {
              _snack('Geofence unassigned from device.');
            } else if (state is GeofenceOperationError) {
              _snack(state.message, color: AppColors.danger);
            }
          },
          builder: (context, state) {
            final isLoading = state is GeofenceLoading;

            final errorMessage = state is GeofenceError ? state.message : null;

            final geofences = state is GeofenceLoaded
                ? state.geofences
                : <GeofenceEntity>[];

            // Device section is a fixed 3-slot layout built from ALL geofences
            // (search does not hide slots).
            final slots = GeofenceSlot.fromGeofences(geofences);

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
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (v) => setState(() => _query = v),
                      decoration: InputDecoration(
                        hintText: 'Search cloud geofences...',
                        prefixIcon: const Icon(Icons.search_rounded),
                        suffixIcon: _query.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _query = '');
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: AppRadius.mdAll,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      ),
                    ),
                  ),

                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                      children: [
                        DeviceGeofenceSlots(
                          slots: slots,
                          modeNameFor: (g) => _conditionFor(g)?.mode?.name,
                          onAddToSlot: (slot) => _assignToSlot(slot, cloudAll),
                          onTap: _onTileTab,
                          onEdit: (g) => _openAddPage(existing: g),
                          onDelete: (g) => _confirmDelete(context, g),
                          onMode: _openModeDialog,
                          onUnassign: _confirmUnassign,
                        ),

                        ..._buildCloudSection(
                          context,
                          items: cloudFiltered,
                          hasAnyCloud: cloudAll.isNotEmpty,
                        ),
                      ],
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

  List<Widget> _buildCloudSection(
    BuildContext context, {
    required List<GeofenceEntity> items,
    required bool hasAnyCloud,
  }) {
    return [
      _SectionHeader(title: 'Synced to cloud', count: items.length),

      if (items.isEmpty)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Center(
            child: Text(
              !hasAnyCloud
                  ? 'No cloud geofences yet.'
                  : 'No geofences match your search.',
              style: TextStyle(color: AppColors.textSecondary(context)),
            ),
          ),
        ),

      for (final g in items)
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: GeofenceListTile(
            geofence: g,
            modeName: _conditionFor(g)?.mode?.name,
            onTap: () => _onTileTab(g),
            onEdit: () => _openAddPage(existing: g),
            onDelete: () => _confirmDelete(context, g),
            onMode: () => _openModeDialog(g),
          ),
        ),
    ];
  }

  void _onTileTab(GeofenceEntity geofence) {
    if (geofence.coordinates.isEmpty) return;

    Navigator.pushNamed(
      context,
      AppRoutes.geofencePreview,
      arguments: GeofencePreviewArgs(geofence: geofence),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;

  const _SectionHeader({required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Text(
        '$title ($count)',
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.textSecondary(context),
        ),
      ),
    );
  }
}
