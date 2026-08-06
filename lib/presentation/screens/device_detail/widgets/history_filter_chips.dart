import 'package:flutter/material.dart';
import '../../../../domain/entities/analytics/analytics_filter.dart';
import '../../../widgets/analytics_filter_sheet.dart'
    show showCustomRangePicker;

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
    final colors = Theme.of(context).colorScheme;
    final items = [..._options.entries];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(
          top: BorderSide(
            color: colors.outlineVariant.withValues(alpha: 0.3),
            width: 1.0,
          ),
        ),
      ),
      child: Row(
        children: [
          for (final e in items) ...[
            Expanded(
              child: _chip(
                context,
                e.value,
                e.key == activeFilter,
                colors,
                isLoading ? null : () => onFilterSelected(e.key),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: _chip(
              context,
              'Custom',
              activeFilter == AnalyticsFilter.custom,
              colors,
              isLoading
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

  Widget _chip(
    BuildContext context,
    String label,
    bool active,
    ColorScheme colors,
    VoidCallback? onTap,
  ) {
    final disabled = onTap == null;

    final activeBg = colors.primary.withValues(alpha: 0.12);
    final activeBorder = colors.primary;
    final activeTextColor = colors.primary;

    final inactiveBg = colors.surface;
    final inactiveBorder = colors.outlineVariant.withValues(alpha: 0.4);
    final inactiveTextColor = colors.onSurface.withValues(alpha: 0.8);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? activeBg : inactiveBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: active ? activeBorder : inactiveBorder,
            width: active ? 1.5 : 1.0,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            fontWeight: active ? FontWeight.w800 : FontWeight.w600,
            color: active
                ? activeTextColor
                : disabled
                ? colors.onSurfaceVariant.withValues(alpha: 0.4)
                : inactiveTextColor,
          ),
        ),
      ),
    );
  }
}
