import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/analytics/analytics_bloc.dart';

class EmptyDataBanner extends StatelessWidget {
  const EmptyDataBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AnalyticsBloc, AnalyticsState>(
      buildWhen: (prev, curr) =>
          (prev is AnalyticsLoaded) != (curr is AnalyticsLoaded),
      builder: (context, state) {
        final loaded = state is AnalyticsLoaded ? state : null;
        if (loaded == null || loaded.points.isNotEmpty) {
          return const SizedBox.shrink();
        }
        final colors = Theme.of(context).colorScheme;
        return Positioned(
          top: MediaQuery.of(context).padding.top + 12,
          left: 64,
          right: 64,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: colors.errorContainer.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: colors.shadow.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: colors.onErrorContainer,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'No data found for this timeframe.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: colors.onErrorContainer,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
