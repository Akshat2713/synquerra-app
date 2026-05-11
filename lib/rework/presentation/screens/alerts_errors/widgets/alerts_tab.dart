// presentation/pages/alerts_errors/widgets/alerts_tab.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../../domain/entities/alerts/alert_error_entity.dart';
import '../../../blocs/alerts/alerts_bloc.dart';
import '../../../widgets/alert_error_card.dart';
import 'empty_view.dart';
import 'failure_view.dart';

class AlertsTab extends StatelessWidget {
  const AlertsTab({super.key});

  static final _fakeItems = List.generate(
    6,
    (_) => const AlertErrorEntity(
      id: 'x',
      imei: 'x',
      topic: 'x',
      code: 'x',
      type: AlertErrorType.alert,
      severity: AlertSeverity.advisory,
      isAcknowledged: false,
      description: 'Loading description text placeholder for skeleton render',
      createdAt: '2024-01-01T00:00:00Z',
      updatedAt: '2024-01-01T00:00:00Z',
    ),
  );

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AlertsBloc, AlertsState>(
      builder: (context, state) {
        final isLoading = state is AlertsLoading;
        final items = switch (state) {
          AlertsLoaded() => state.alerts,
          _ => _fakeItems,
        };

        if (state is AlertsFailure) {
          return FailureView(message: state.message);
        }

        if (state is AlertsLoaded && state.alerts.isEmpty) {
          return const EmptyView(label: 'No alerts found');
        }

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
