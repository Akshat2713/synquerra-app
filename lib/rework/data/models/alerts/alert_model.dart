import '../../../domain/entities/alerts/alert_entity.dart';

class AlertModel {
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

  const AlertModel({
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

  factory AlertModel.fromJson(Map<String, dynamic> json) => AlertModel(
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

  AlertEntity toEntity() => AlertEntity(
    id: id,
    imei: imei,
    topic: topic,
    code: code,
    type: type == 'alert' ? AlertType.alert : AlertType.unknown,
    severity: severity == 'critical'
        ? AlertSeverity.critical
        : severity == 'advisory'
        ? AlertSeverity.advisory
        : AlertSeverity.unknown,
    isAcknowledged: isAcknowledged,
    description: description,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}
