import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:synquerra/domain/entities/schedule/schedule_entity.dart';
import 'package:synquerra/presentation/themes/app_text_styles.dart';
import 'package:synquerra/presentation/themes/app_tokens.dart';
import 'package:synquerra/presentation/themes/colors.dart';
import 'package:synquerra/presentation/utils/app_icons.dart';
import 'package:synquerra/presentation/utils/colour_util.dart';
import 'package:synquerra/presentation/utils/date_time_formatter.dart';
import 'package:synquerra/presentation/utils/unit_formatter.dart';
import 'package:synquerra/presentation/widgets/app_surfaces.dart';

enum _Menu { edit, delete }

class ScheduleCard extends StatelessWidget {
  final ScheduleEntity schedule;
  final bool isProcessing;
  final ValueChanged<bool> onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onTap;

  const ScheduleCard({
    super.key,
    required this.schedule,
    required this.isProcessing,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final description = (schedule.description ?? '').trim();

    return IgnorePointer(
      ignoring: isProcessing,
      child: AppCard(
        padding: EdgeInsets.zero,
        child: Material(
          type: MaterialType.transparency,
          borderRadius: AppRadius.lgAll,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap == null
                ? null
                : () {
                    HapticFeedback.selectionClick();
                    onTap!();
                  },
            child: Padding(
              padding: AppSpacing.mdAll,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: AppSpacing.smd,
                children: [
                  _Header(
                    schedule: schedule,
                    isProcessing: isProcessing,
                    onToggle: onToggle,
                  ),
                  if (description.isNotEmpty)
                    Text(
                      description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.metaWithColor(context),
                    ),
                  _TimeStrip(schedule: schedule),
                  // _DaysRow(schedule: schedule),
                  _Footer(
                    schedule: schedule,
                    onEdit: onEdit,
                    onDelete: onDelete,
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

class _Header extends StatelessWidget {
  final ScheduleEntity schedule;
  final bool isProcessing;
  final ValueChanged<bool> onToggle;

  const _Header({
    required this.schedule,
    required this.isProcessing,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final active = schedule.isActive;
    return Row(
      spacing: AppSpacing.smd,
      children: [
        IconTile(
          icon: AppIcons.schedule,
          background: active
              ? AppColors.primary(context)
              : AppColors.surfaceVariant(context),
          foreground: active
              ? AppColors.onPrimary(context)
              : AppColors.iconSecondary(context),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                schedule.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.sectionWithColor(context),
              ),
              Text(
                UnitFormatter.formatDays(schedule.daysOfWeek),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.metaWithColor(context),
              ),
            ],
          ),
        ),
        if (isProcessing)
          const SizedBox.square(
            dimension: AppSize.tapTarget,
            child: Center(
              child: SizedBox.square(
                dimension: AppSize.icon,
                child: CircularProgressIndicator(strokeWidth: AppSize.stroke),
              ),
            ),
          )
        else
          MergeSemantics(
            child: Semantics(
              label: schedule.title,
              child: Switch(value: active, onChanged: onToggle),
            ),
          ),
      ],
    );
  }
}

class _TimeStrip extends StatelessWidget {
  final ScheduleEntity schedule;

  const _TimeStrip({required this.schedule});

  @override
  Widget build(BuildContext context) {
    final active = schedule.isActive;
    final foreground = active
        ? AppColors.onPrimaryContainer(context)
        : AppColors.textSecondary(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.smd,
      ),
      decoration: BoxDecoration(
        color: active
            ? AppColors.primaryContainer(context)
            : AppColors.surfaceVariant(context),
        borderRadius: AppRadius.mdAll,
      ),
      child: Row(
        spacing: AppSpacing.sm,
        children: [
          Icon(AppIcons.time, size: AppSize.icon, color: foreground),
          Expanded(
            child: Text(
              '${DateTimeFormatter.formatTimeString(schedule.startTime)} – '
              '${DateTimeFormatter.formatTimeString(schedule.endTime)}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.sectionWithColor(context, color: foreground),
            ),
          ),
          Icon(
            AppIcons.chevron,
            size: AppSize.icon,
            color: active
                ? AppColors.primary(context)
                : AppColors.iconSecondary(context),
          ),
        ],
      ),
    );
  }
}

// class _DaysRow extends StatelessWidget {
//   static const _labels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

//   final ScheduleEntity schedule;

//   const _DaysRow({required this.schedule});

//   @override
//   Widget build(BuildContext context) {
//     final active = schedule.isActive;

//     return Semantics(
//       label: 'Runs ${UnitFormatter.formatDays(schedule.daysOfWeek)}',
//       excludeSemantics: true,
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: List.generate(_labels.length, (i) {
//           final selected = schedule.daysOfWeek.contains(i);
//           final (bg, fg) = !selected
//               ? (
//                   AppColors.surfaceVariant(context),
//                   AppColors.textTertiary(context),
//                 )
//               : active
//               ? (AppColors.primary(context), AppColors.onPrimary(context))
//               : (AppColors.outline(context), AppColors.textSecondary(context));

//           return Container(
//             width: AppSize.avatarSm,
//             height: AppSize.avatarSm,
//             alignment: Alignment.center,
//             decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
//             child: Text(
//               _labels[i],
//               style: AppTextStyles.metaWithColor(
//                 context,
//                 color: fg,
//               ).copyWith(fontWeight: FontWeight.w700),
//             ),
//           );
//         }),
//       ),
//     );
//   }
// }

class _Footer extends StatelessWidget {
  final ScheduleEntity schedule;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _Footer({
    required this.schedule,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final priority = schedule.priority.trim();
    final neutralBg = AppColors.surfaceVariant(context);
    final neutralFg = AppColors.textSecondary(context);

    return Row(
      children: [
        Expanded(
          child: Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              if (!schedule.isActive)
                InfoPill(
                  // icon: AppIcons.pause,
                  label: 'Inactive',
                  background: AppColors.offlineContainer,
                  foreground: neutralFg,
                ),
              if (priority.isNotEmpty)
                InfoPill(
                  label:
                      '${toBeginningOfSentenceCase(priority.toLowerCase())} priority',
                  dotColor: priorityColor(priority),
                  background: AppAlpha.withAlpha(
                    priorityColor(priority),
                    AppAlpha.fill,
                  ),
                  foreground: AppColors.textPrimary(context),
                ),
              if (schedule.startDate.isNotEmpty)
                InfoPill(
                  icon: AppIcons.date,
                  label: DateTimeFormatter.formatDateRange(
                    schedule.startDate,
                    schedule.endDate,
                  ),
                  background: neutralBg,
                  foreground: neutralFg,
                ),
              if (schedule.crossesMidnight)
                InfoPill(
                  icon: AppIcons.overnight,
                  label: 'Overnight',
                  background: neutralBg,
                  foreground: neutralFg,
                ),
            ],
          ),
        ),
        PopupMenuButton<_Menu>(
          tooltip: 'More options',
          icon: Icon(AppIcons.more, color: AppColors.iconSecondary(context)),
          onSelected: (value) {
            switch (value) {
              case _Menu.edit:
                onEdit();
              case _Menu.delete:
                onDelete();
            }
          },
          itemBuilder: (_) => [
            PopupMenuItem(
              value: _Menu.edit,
              child: Row(
                spacing: AppSpacing.sm,
                children: [
                  Icon(AppIcons.edit, size: AppSize.icon),
                  const Text('Edit'),
                ],
              ),
            ),
            PopupMenuItem(
              value: _Menu.delete,
              child: Row(
                spacing: AppSpacing.sm,
                children: [
                  Icon(
                    AppIcons.delete,
                    size: AppSize.icon,
                    color: AppColors.danger,
                  ),
                  const Text('Delete'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
