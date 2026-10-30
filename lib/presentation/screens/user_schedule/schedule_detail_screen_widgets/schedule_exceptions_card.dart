import 'package:flutter/material.dart';
import 'package:synquerra/presentation/themes/app_text_styles.dart';
import 'package:synquerra/presentation/themes/app_tokens.dart';
import 'package:synquerra/presentation/themes/colors.dart';
import 'package:synquerra/presentation/utils/app_icons.dart';
import 'package:synquerra/presentation/widgets/app_surfaces.dart';

import '../../../../domain/entities/schedule/schedule_override_entity.dart';
import 'detail_card_parts.dart';

class ScheduleExceptionsCard extends StatelessWidget {
  final List<ScheduleOverrideEntity> overrides;
  final Set<String> processingIds;
  final VoidCallback onAddException;
  final ValueChanged<ScheduleOverrideEntity> onEditException;
  final ValueChanged<ScheduleOverrideEntity> onDeleteException;

  const ScheduleExceptionsCard({
    super.key,
    required this.overrides,
    required this.onAddException,
    required this.onEditException,
    required this.onDeleteException,
    this.processingIds = const {},
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: AppSpacing.smd,
        children: [
          DetailCardHeader(
            title: 'Schedule Exceptions (${overrides.length})',
            icon: AppIcons.eventBusy,
            background: AppColors.warning,
            foreground: AppColors.onWarning,
            trailing: IconButton.filled(
              tooltip: 'Add exception',
              icon: Icon(AppIcons.add, color: AppColors.onPrimary(context)),
              onPressed: onAddException,
            ),
          ),
          if (overrides.isEmpty)
            InsetRow(
              child: Row(
                spacing: AppSpacing.sm,
                children: [
                  Icon(
                    AppIcons.info,
                    size: AppSize.iconSm,
                    color: AppColors.offline,
                  ),
                  Expanded(
                    child: Text(
                      'No custom exceptions configured for this schedule.',
                      style: AppTextStyles.metaWithColor(context),
                    ),
                  ),
                ],
              ),
            )
          else
            Column(children: [for (final o in overrides) _item(context, o)]),
        ],
      ),
    );
  }

  Widget _item(BuildContext context, ScheduleOverrideEntity o) {
    final isCancel = o.overrideType.toUpperCase() == 'CANCEL';
    final isProcessing = processingIds.contains(o.id);
    final hasTimes = !isCancel && o.startTime != null && o.endTime != null;
    final reason = o.reason;

    return InsetRow(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: AppSpacing.xs,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  o.date,
                  style: AppTextStyles.bodyWithColor(
                    context,
                    color: AppColors.textPrimary(context),
                  ).copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              if (isProcessing)
                const SizedBox.square(
                  dimension: AppSize.tile,
                  child: Center(
                    child: SizedBox.square(
                      dimension: AppSize.iconSm,
                      child: CircularProgressIndicator(
                        strokeWidth: AppSize.stroke,
                      ),
                    ),
                  ),
                )
              else ...[
                IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: 'Edit exception',
                  icon: Icon(
                    AppIcons.edit,
                    size: AppSize.icon,
                    color: AppColors.iconSecondary(context),
                  ),
                  onPressed: () => onEditException(o),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: 'Delete exception',
                  icon: Icon(
                    AppIcons.delete,
                    size: AppSize.icon,
                    color: AppColors.danger,
                  ),
                  onPressed: () => onDeleteException(o),
                ),
              ],
            ],
          ),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              InfoPill(
                label: isCancel ? 'Cancelled' : 'Modified Hours',
                dotColor: isCancel
                    ? AppColors.danger
                    : AppColors.primary(context),
                background: AppColors.surface(context),
                foreground: AppColors.textPrimary(context),
              ),
              if (hasTimes)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: AppSpacing.xs,
                  children: [
                    Icon(
                      AppIcons.time,
                      size: AppSize.iconSm,
                      color: AppColors.textSecondary(context),
                    ),
                    Text(
                      '${o.startTime} - ${o.endTime}',
                      style: AppTextStyles.metaWithColor(context),
                    ),
                  ],
                ),
            ],
          ),
          if (reason != null && reason.isNotEmpty)
            Text(
              'Reason: $reason',
              style: AppTextStyles.metaWithColor(context),
            ),
        ],
      ),
    );
  }
}
