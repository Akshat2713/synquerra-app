import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/analytics/analytics_bloc.dart';
import '../../../themes/colors.dart';

class EmptyDataBanner extends StatelessWidget {
  const EmptyDataBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AnalyticsBloc, AnalyticsState>(
      buildWhen: (prev, curr) {
        if (prev is AnalyticsLoaded && curr is AnalyticsLoaded) {
          return prev.points.isEmpty != curr.points.isEmpty;
        }
        return prev.runtimeType != curr.runtimeType;
      },
      builder: (context, state) {
        final loaded = state is AnalyticsLoaded ? state : null;
        if (loaded == null || loaded.points.isNotEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.dangerContainer.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow(context).withValues(alpha: 0.1),
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
                color: AppColors.danger,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'No data found for this timeframe.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.danger,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
