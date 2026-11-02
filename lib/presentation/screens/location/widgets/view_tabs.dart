import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../themes/app_text_styles.dart';
import '../../../themes/colors.dart';
import '../../../widgets/app_surfaces.dart';
import '../../../themes/app_tokens.dart';

class ViewTabs extends StatelessWidget {
  final bool isHistory;
  final ValueChanged<bool> onChanged; // true = History
  const ViewTabs({super.key, required this.isHistory, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: AppSpacing.xsAll,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Segment(
            label: 'Latest',
            active: !isHistory,
            onTap: () => onChanged(false),
          ),
          _Segment(
            label: 'History',
            active: isHistory,
            onTap: () => onChanged(true),
          ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _Segment({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return Semantics(
      button: true,
      selected: active,
      label: label,
      child: AnimatedContainer(
        duration: reduceMotion ? Duration.zero : AppMotion.base,
        curve: AppMotion.curve,
        decoration: BoxDecoration(
          color: active ? AppColors.primary(context) : null,
          borderRadius: AppRadius.lgAll,
        ),
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
                vertical: AppSpacing.sm,
              ),
              child: Text(
                label,
                style: AppTextStyles.bodyWithColor(
                  context,
                  color: active
                      ? AppColors.onPrimary(context)
                      : AppColors.textSecondary(context),
                ).copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
