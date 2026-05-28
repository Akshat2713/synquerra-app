import '../../../../domain/entities/alerts/alert_error_entity.dart';

final List<AlertErrorEntity> fakeAlertErrorSkeletonItems = List.generate(
  6,
  (_) => const AlertErrorEntity(
    id: 'x',
    imei: 'x',
    topic: 'x',
    code: 'x',
    type: AlertErrorType.alert, // Type doesn't matter for the skeleton render
    severity: AlertSeverity.advisory,
    isAcknowledged: false,
    description: 'Loading description text placeholder for skeleton render',
    createdAt: '2024-01-01T00:00:00Z',
    updatedAt: '2024-01-01T00:00:00Z',
  ),
);
