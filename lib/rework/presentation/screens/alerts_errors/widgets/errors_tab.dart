// presentation/pages/alerts_errors/widgets/errors_tab.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../../domain/entities/alerts/alert_error_entity.dart';
// import '../../../blocs/errors/errors_bloc.dart';
import '../../../blocs/alerts_errors/alerts_errors_bloc.dart';
import '../../../widgets/alert_error_card.dart';
import 'empty_view.dart';
import 'failure_view.dart';
// import 'alert_error_card.dart';

class ErrorsTab extends StatelessWidget {
  const ErrorsTab({super.key});

  static final _fakeItems = List.generate(
    6,
    (_) => const AlertErrorEntity(
      id: 'x',
      imei: 'x',
      topic: 'x',
      code: 'x',
      type: AlertErrorType.error,
      severity: AlertSeverity.advisory,
      isAcknowledged: false,
      description: 'Loading description text placeholder for skeleton render',
      createdAt: '2024-01-01T00:00:00Z',
      updatedAt: '2024-01-01T00:00:00Z',
    ),
  );

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AlertsErrorsBloc, AlertsErrorsState>(
      builder: (context, state) {
        if (state is AlertsErrorsFailure) {
          return FailureView(message: state.message);
        }
        if (state is AlertsErrorsLoaded && state.errors.isEmpty) {
          return const EmptyView(label: 'No errors found');
        }
        final isLoading = state is AlertsErrorsLoading;
        final items = state is AlertsErrorsLoaded ? state.errors : _fakeItems;
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
