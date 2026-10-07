import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:synquerra/presentation/themes/colors.dart';
import '../../../../data/datasources/graphql/mode_conditions_query.dart';
import '../../../../domain/entities/geofence/geofence_entity.dart';
import '../../../../domain/entities/geofence_mode/geofence_mode_entity.dart';
import '../../../../domain/entities/geofence_mode/mode_condition_entity.dart';
import '../../../blocs/mode_condition/mode_condition_bloc.dart';

class ConfigureTriggerModeDialog extends StatefulWidget {
  final String deviceId;
  final GeofenceEntity geofence;

  /// The mode condition already attached to this geofence (null = create).
  final ModeConditionEntity? existing;

  const ConfigureTriggerModeDialog({
    super.key,
    required this.deviceId,
    required this.geofence,
    this.existing,
  });

  @override
  State<ConfigureTriggerModeDialog> createState() =>
      _ConfigureTriggerModeDialogState();
}

class _ConfigureTriggerModeDialogState
    extends State<ConfigureTriggerModeDialog> {
  String? _selectedModeId;

  /// Synced to device -> device_geofence, otherwise -> geofence.
  /// The same string is used as the modes category.
  String get _conditionType => widget.geofence.isSyncToDevice
      ? ModeConditionType.deviceGeofence
      : ModeConditionType.geofence;

  @override
  void initState() {
    super.initState();
    _selectedModeId = widget.existing?.modeId;
    context.read<ModeConditionBloc>().add(
      ModeConditionLoadModes(_conditionType),
    );
  }

  void _save() {
    final bloc = context.read<ModeConditionBloc>();
    final config = {'geofence_id': widget.geofence.id};
    final existing = widget.existing;

    if (existing != null) {
      bloc.add(
        ModeConditionUpdate(
          conditionId: existing.id,
          deviceId: widget.deviceId,
          modeId: _selectedModeId!,
          conditionType: _conditionType,
          config: config,
        ),
      );
    } else {
      bloc.add(
        ModeConditionCreate(
          deviceId: widget.deviceId,
          modeId: _selectedModeId!,
          conditionType: _conditionType,
          config: config,
        ),
      );
    }
    Navigator.pop(context);
  }

  void _delete() {
    context.read<ModeConditionBloc>().add(
      ModeConditionDelete(
        deviceId: widget.deviceId,
        conditionId: widget.existing!.id,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AlertDialog(
      title: const Text('Configure trigger mode'),
      content: SizedBox(
        width: double.maxFinite,
        child: BlocBuilder<ModeConditionBloc, ModeConditionState>(
          buildWhen: (_, s) => s is ModeConditionLoaded,
          builder: (context, state) {
            final ready =
                state is ModeConditionLoaded &&
                state.modesCategory == _conditionType;

            if (!ready) {
              return const SizedBox(
                height: 80,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            final modes = state.modes;
            if (modes.isEmpty) {
              return const Text('No modes available.');
            }

            // Guard: the saved mode may not be in the list anymore.
            final hasSelected = modes.any((m) => m.id == _selectedModeId);
            final selected = hasSelected
                ? modes.firstWhere((m) => m.id == _selectedModeId)
                : null;

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.geofence.geofenceName,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: hasSelected ? _selectedModeId : null,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: 'Mode',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: modes
                      .map(
                        (GeofenceModeEntity m) => DropdownMenuItem(
                          value: m.id,
                          child: Text(m.name, overflow: TextOverflow.ellipsis),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _selectedModeId = v),
                ),
                const SizedBox(height: 16),
                Text(
                  'Description',
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary(context),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(minHeight: 80),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surface(context),
                    border: Border.all(
                      color: AppColors.outlineVariant(context),
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    selected?.displayDescription ??
                        'Select a mode to see its description.',
                    style: textTheme.bodyMedium,
                  ),
                ),
              ],
            );
          },
        ),
      ),
      actions: [
        if (widget.existing != null)
          TextButton(
            onPressed: _delete,
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('Remove'),
          ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _selectedModeId == null ? null : _save,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
