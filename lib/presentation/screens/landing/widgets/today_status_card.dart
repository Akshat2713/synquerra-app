import 'package:flutter/material.dart';
import '../../../themes/app_text_styles.dart';
import '../../../themes/app_tokens.dart';
import '../../../themes/colors.dart';
import '../../../widgets/app_surfaces.dart';
import '../../../widgets/expandable_card.dart';

// TODO(logic): move to domain/entities once real data is wired.
class StatusLogEntry {
  final String label;
  final String value;
  final bool isHighlightValue;

  const StatusLogEntry({
    required this.label,
    required this.value,
    this.isHighlightValue = false,
  });
}

class TodayStatusCard extends StatelessWidget {
  final bool looksNormal;
  final List<StatusLogEntry> logs;

  const TodayStatusCard({
    super.key,
    required this.looksNormal,
    required this.logs,
  });

  @override
  Widget build(BuildContext context) {
    return ExpandableCard(
      leading: IconTile(
        icon: looksNormal ? Icons.check_circle_rounded : Icons.insights_rounded,
        background: looksNormal ? AppColors.success : AppColors.warning,
        foreground: looksNormal ? AppColors.onSuccess : AppColors.onWarning,
      ),
      title: looksNormal ? 'Today looks normal' : 'Today has changes',
      child: logs.isEmpty
          ? const ExpandableCardEmpty('Nothing logged yet today.')
          : Column(children: [for (final log in logs) _LogRow(log: log)]),
    );
  }
}

class _LogRow extends StatelessWidget {
  final StatusLogEntry log;
  const _LogRow({required this.log});

  @override
  Widget build(BuildContext context) => InsetRow(
    onTap: () {}, // TODO(logic): wire destination
    child: Row(
      children: [
        const Icon(Icons.circle, size: AppSize.dot, color: AppColors.success),
        const SizedBox(width: AppSpacing.smd),
        Expanded(
          child: Text(log.label, style: AppTextStyles.bodyWithColor(context)),
        ),
        log.isHighlightValue
            ? InfoPill(
                label: log.value,
                background: AppColors.successContainer,
                foreground: AppColors.success,
              )
            : Text(
                log.value,
                style: AppTextStyles.bodyWithColor(
                  context,
                  color: AppColors.textPrimary(context),
                ).copyWith(fontWeight: FontWeight.w600),
              ),
      ],
    ),
  );
}
