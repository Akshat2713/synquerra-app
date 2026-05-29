// presentation/pages/alerts_errors/widgets/alerts_tab.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../../domain/entities/alerts/alert_error_entity.dart';
import '../../../blocs/alerts_errors/alerts_errors_bloc.dart';
import '../../../widgets/alert_error_card.dart';
import 'alert_error_skeleton.dart';
import 'empty_view.dart';
import 'failure_view.dart';

class AlertsTab extends StatelessWidget {
  const AlertsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AlertsErrorsBloc, AlertsErrorsState>(
      builder: (context, state) {
        if (state is AlertsErrorsFailure) {
          return FailureView(message: state.message);
        }
        if (state is AlertsErrorsLoaded && state.alerts.isEmpty) {
          return const EmptyView(label: 'No alerts found');
        }
        final isLoading = state is AlertsErrorsLoading;
        final items = state is AlertsErrorsLoaded
            ? state.alerts
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
