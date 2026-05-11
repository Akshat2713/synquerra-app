import '../../../domain/entities/alerts/alert_error_entity.dart';

class AlertErrorModel {
  final String id;
  final String imei;
  final String topic;
  final String code;
  final String type;
  final String severity;
  final bool isAcknowledged;
  final String description;
  final String createdAt;
  final String updatedAt;

  const AlertErrorModel({
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

  factory AlertErrorModel.fromJson(Map<String, dynamic> json) =>
      AlertErrorModel(
        id: json['id'] as String,
        imei: json['imei'] as String,
        topic: json['topic'] as String,
        code: json['code'] as String,
        type: json['type'] as String,
        severity: json['severity'] as String,
        isAcknowledged: json['is_acknowledged'] as bool,
        description: json['description'] as String,
        createdAt: json['createdAt'] as String,
        updatedAt: json['updatedAt'] as String,
      );

  AlertErrorEntity toEntity() => AlertErrorEntity(
    id: id,
    imei: imei,
    topic: topic,
    code: code,
    type: type == 'alert' ? AlertErrorType.alert : AlertErrorType.error,
    severity: severity == 'critical'
        ? AlertSeverity.critical
        : severity == 'advisory'
        ? AlertSeverity.advisory
        : AlertSeverity.warning,
    isAcknowledged: isAcknowledged,
    description: description,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}
