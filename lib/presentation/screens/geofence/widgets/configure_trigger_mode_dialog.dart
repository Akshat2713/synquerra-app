import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/datasources/graphql/mode_conditions_query.dart';
import '../../../../domain/entities/geofence/geofence_entity.dart';
import '../../../../domain/entities/geofence_mode/geofence_mode_entity.dart';
import '../../../../domain/entities/geofence_mode/mode_condition_entity.dart';
import '../../../blocs/mode_condition/mode_condition_bloc.dart';
import '../../../themes/app_text_styles.dart';
import '../../../themes/app_tokens.dart';
import '../../../themes/colors.dart';
import '../../../utils/app_icons.dart';
import '../../../widgets/app_surfaces.dart';

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
  /// TODO(logic): move condition-type mapping to bloc/utils.
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
    return AlertDialog(
      insetPadding: AppSpacing.mdHorizontal,
      actionsPadding: AppSpacing.mdAll,
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
              return Center(
                child: Padding(
                  padding: AppSpacing.lgAll,
                  child: const CircularProgressIndicator(),
                ),
              );
            }

            final modes = state.modes;
            if (modes.isEmpty) {
              return Text(
                'No modes available.',
                style: AppTextStyles.bodyWithColor(context),
              );
            }

            // Guard: the saved mode may not be in the list anymore.
            final hasSelected = modes.any((m) => m.id == _selectedModeId);
            final selected = hasSelected
                ? modes.firstWhere((m) => m.id == _selectedModeId)
                : null;

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: AppSpacing.md,
              children: [
                AppCard(
                  tint: AppColors.primaryContainer(context),
                  padding: AppSpacing.smAll,
                  child: Row(
                    spacing: AppSpacing.sm,
                    children: [
                      Icon(
                        AppIcons.geofence,
                        size: AppSize.icon,
                        color: AppColors.onPrimaryContainer(context),
                      ),
                      Expanded(
                        child: Text(
                          widget.geofence.geofenceName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodyWithColor(
                            context,
                            color: AppColors.onPrimaryContainer(context),
                          ).copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
                DropdownButtonFormField<String>(
                  initialValue: hasSelected ? _selectedModeId : null,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Mode'),
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: AppSpacing.xs,
                  children: [
                    Text(
                      'Description',
                      style: AppTextStyles.metaWithColor(context),
                    ),
                    InsetRow(
                      child: Text(
                        selected?.displayDescription ??
                            'Select a mode to see its description.',
                        style: AppTextStyles.bodyWithColor(
                          context,
                          color: AppColors.textPrimary(context),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
      actions: [
        Row(
          spacing: AppSpacing.sm,
          children: [
            if (widget.existing != null)
              TextButton.icon(
                onPressed: _delete,
                icon: Icon(AppIcons.delete, color: AppColors.danger),
                label: const Text('Remove'),
              ),
            const Spacer(),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: _selectedModeId == null ? null : _save,
              child: const Text('Save'),
            ),
          ],
        ),
      ],
    );
  }
}
