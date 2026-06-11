// presentation/screens/alerts_errors/widgets/alerts_errors_tab.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../blocs/alerts_errors/alerts_errors_bloc.dart';
import '../../../widgets/alert_error_card.dart';
import 'alert_error_skeleton.dart';
import 'empty_view.dart';
import 'failure_view.dart';

enum AlertsErrorsTabType { alerts, errors }

class AlertsErrorsTab extends StatelessWidget {
  final AlertsErrorsTabType type;

  const AlertsErrorsTab({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AlertsErrorsBloc, AlertsErrorsState>(
      builder: (context, state) {
        if (state is AlertsErrorsFailure) {
          return FailureView(message: state.message);
        }

        final isAlerts = type == AlertsErrorsTabType.alerts;

        if (state is AlertsErrorsLoaded) {
          final items = isAlerts ? state.alerts : state.errors;
          if (items.isEmpty) {
            return EmptyView(
              label: isAlerts ? 'No alerts found' : 'No errors found',
            );
          }
        }

        final isLoading = state is AlertsErrorsLoading;
        final items = state is AlertsErrorsLoaded
            ? (isAlerts ? state.alerts : state.errors)
            : fakeAlertErrorSkeletonItems;

        return Skeletonizer(
          enabled: isLoading,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 10),
            itemCount: items.length,
            itemBuilder: (_, i) => AlertErrorCard(item: items[i]),
          ),
        );
      },
    );
  }
}
