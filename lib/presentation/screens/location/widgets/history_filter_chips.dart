import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../domain/entities/analytics/analytics_filter.dart';
import '../../../themes/app_text_styles.dart';
import '../../../themes/colors.dart';
import '../../../widgets/analytics_filter_sheet.dart';
import '../../../themes/app_tokens.dart';

class HistoryFilterChips extends StatelessWidget {
  final AnalyticsFilter activeFilter;
  final ValueChanged<AnalyticsFilter> onFilterSelected;
  final void Function(DateTime start, DateTime end) onCustomSelected;
  final bool isLoading;

  const HistoryFilterChips({
    super.key,
    required this.activeFilter,
    required this.onFilterSelected,
    required this.onCustomSelected,
    this.isLoading = false,
  });

  static const _options = {
    AnalyticsFilter.lastHour: '1H',
    AnalyticsFilter.last2Hours: '2H',
    AnalyticsFilter.last6Hours: '6H',
    AnalyticsFilter.last12Hours: '12H',
    AnalyticsFilter.last24Hours: '24H',
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.smd,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        border: Border(
          top: BorderSide(
            color: AppAlpha.withBorderAlpha(AppColors.outlineVariant(context)),
            width: AppSize.hairline,
          ),
        ),
      ),
      child: Row(
        spacing: AppSpacing.sm,
        children: [
          for (final e in _options.entries)
            Expanded(
              child: _FilterChip(
                label: e.value,
                active: e.key == activeFilter,
                onTap: isLoading ? null : () => onFilterSelected(e.key),
              ),
            ),
          Expanded(
            child: _FilterChip(
              label: 'Custom',
              active: activeFilter == AnalyticsFilter.custom,
              onTap: isLoading
                  ? null
                  : () => showCustomRangePicker(
                      context: context,
                      onCustomSelected: onCustomSelected,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback? onTap;

  const _FilterChip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final primary = AppColors.primary(context);

    final textColor = active
        ? AppColors.onPrimary(context)
        : disabled
        ? AppAlpha.withAlpha(
            AppColors.textSecondary(context),
            AppAlpha.disabled,
          )
        : AppColors.textSecondary(context);

    return Semantics(
      button: true,
      selected: active,
      enabled: !disabled,
      label: label,
      child: AnimatedContainer(
        duration: reduceMotion ? Duration.zero : AppMotion.base,
        curve: AppMotion.curve,
        decoration: BoxDecoration(
          color: active ? primary : AppColors.surfaceVariant(context),
          borderRadius: AppRadius.mdAll,
          border: Border.all(
            color: active
                ? primary
                : AppAlpha.withBorderAlpha(AppColors.outlineVariant(context)),
            width: AppSize.hairline,
          ),
        ),
        child: Material(
          type: MaterialType.transparency,
          borderRadius: AppRadius.mdAll,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: disabled
                ? null
                : () {
                    HapticFeedback.selectionClick();
                    onTap!();
                  },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.smd),
              child: Center(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.meta.copyWith(
                    color: textColor,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
