import 'package:flutter/material.dart';

import '../../../../domain/entities/modes/mode_entity.dart';
import '../../../themes/app_text_styles.dart';
import '../../../themes/app_tokens.dart';
import '../../../themes/colors.dart';
import '../../../utils/app_icons.dart';
import '../../../utils/unit_formatter.dart';
import '../../../widgets/app_overlays.dart';
import '../../../widgets/app_surfaces.dart';

void showModeDetailsSheet(BuildContext context, ModeEntity mode) =>
    showAppBottomSheet(context, builder: (_) => ModeDetailsSheet(mode: mode));

class ModeDetailsSheet extends StatelessWidget {
  final ModeEntity mode;
  const ModeDetailsSheet({super.key, required this.mode});

  Map<String, List<(String, String)>> get _groups => {
    'Intervals': [
      (
        'Normal sending',
        UnitFormatter.formatDuration(mode.normalSendingInterval),
      ),
      ('SOS sending', UnitFormatter.formatDuration(mode.sosSendingInterval)),
      (
        'Normal scanning',
        UnitFormatter.formatDuration(mode.normalScanningInterval),
      ),
      (
        'Airplane interval',
        UnitFormatter.formatDuration(mode.airplaneInterval),
      ),
    ],
    'Limits & thresholds': [
      (
        'Temperature limit',
        UnitFormatter.formatTemperature(mode.temperatureLimit),
      ),
      ('Speed limit', UnitFormatter.formatSpeed(mode.speedLimit, decimals: 0)),
      ('Low battery limit', '${mode.lowbatLimit}%'),
    ],
    'Configuration & status': [
      ('Priority', '${mode.priority}'),
      (
        'Reconfirmation time',
        UnitFormatter.formatDuration(mode.reconfirmationTime),
      ),
      ('Airplane mode', mode.airplaneMode ? 'Enabled' : 'Disabled'),
      ('Ambient listening', mode.ambientListeningStatus),
      ('LED status', mode.ledStatus ? 'Enabled' : 'Disabled'),
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconTile(
                icon: AppIcons.mode(mode),
                background: AppColors.primaryContainer(context),
                foreground: AppColors.primary(context),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mode.name,
                      style: AppTextStyles.titleWithColor(context),
                    ),
                    if (mode.description.isNotEmpty)
                      Text(
                        mode.description,
                        style: AppTextStyles.metaWithColor(context),
                      ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Close',
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const Divider(height: AppSpacing.lg),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: [
                for (final g in _groups.entries) ...[
                  _SectionTitle(g.key),
                  for (final (label, value) in g.value)
                    _DetailRow(label, value),
                ],
                if (mode.note.isNotEmpty) ...[
                  const _SectionTitle('Note'),
                  Text(mode.note, style: AppTextStyles.bodyWithColor(context)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: AppSpacing.md, bottom: AppSpacing.sm),
    child: Text(
      title.toUpperCase(),
      style: AppTextStyles.microWithColor(
        context,
        color: AppColors.primary(context),
      ),
    ),
  );
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) => Padding(
    padding: AppSpacing.xsVertical,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodyWithColor(context)),
        Text(value, style: AppTextStyles.sectionWithColor(context)),
      ],
    ),
  );
}
