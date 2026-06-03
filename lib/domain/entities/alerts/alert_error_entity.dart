import 'package:equatable/equatable.dart';

enum AlertSeverity { critical, advisory, warning }

enum AlertErrorType { alert, error }

class AlertErrorEntity extends Equatable {
  final String id;
  final String imei;
  final String topic;
  final String code;
  final AlertErrorType type;
  final AlertSeverity severity;
  final bool isAcknowledged;
  final String description;
  final String createdAt;
  final String updatedAt;

  const AlertErrorEntity({
    required this.id,
    required this.imei,
    required this.topic,
    required this.code,
    required this.type,
    required this.severity,
    required this.isAcknowledged,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isCritical => severity == AlertSeverity.critical;

  @override
  List<Object?> get props => [
    id,
    imei,
    topic,
    code,
    type,
    severity,
    isAcknowledged,
    description,
    createdAt,
    updatedAt,
  ];
}
