// lib/data/mappers/analytics_mapper.dart
import '../../business/entities/analytics_entity.dart';
import '../models/analytics_model.dart';
import 'type_converter.dart';

class AnalyticsMapper {
  const AnalyticsMapper();

  /// Convert AnalyticsDataModel to Entity
  AnalyticsDataEntity toEntity(AnalyticsDataModel model) {
    return AnalyticsDataEntity(
      id: model.id,
      imei: model.imei,
      packetType: model.packetType,
      interval: model.interval,
      geoid: model.geoid,
      latitude: model.latitude,
      longitude: model.longitude,
      speed: model.speed,
      battery: model.battery,
      signal: model.signal,
      timestamp: model.timestamp,
      alert: model.alert,
      temperature: model.temperature,
    );
  }

  /// Convert JSON to AnalyticsDataModel
  AnalyticsDataModel fromJson(Map<String, dynamic> json) {
    return AnalyticsDataModel(
      id: json['id'] ?? '',
      imei: json['imei'] ?? '',
      packetType: json['packet'] ?? 'Unknown',
      interval: json['interval']?.toString(),
      geoid: json['geoid']?.toString(),
      latitude: TypeConverter.parseDouble(json['latitude']),
      longitude: TypeConverter.parseDouble(json['longitude']),
      speed: TypeConverter.parseDouble(json['speed']),
      battery: TypeConverter.parseBattery(json['battery']),
      signal: TypeConverter.parseSignal(json['signal']),
      timestamp:
          TypeConverter.parseDateTime(json['timestamp']) ?? DateTime.now(),
      alert: json['alert'],
      temperature: TypeConverter.parseInt(
        TypeConverter.cleanTemperature(json['rawTemperature']),
      ),
    );
  }

  /// Convert JSON to AnalyticsDistanceModel
  AnalyticsDistanceModel distanceFromJson(Map<String, dynamic> json) {
    return AnalyticsDistanceModel(
      hour: json['hour'] ?? '',
      distance: (json['distance'] as num?)?.toDouble() ?? 0.0,
      cumulative: (json['cumulative'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// Convert JSON to AnalyticsHealthModel
  AnalyticsHealthModel healthFromJson(Map<String, dynamic> json) {
    return AnalyticsHealthModel(
      gpsScore: (json['gpsScore'] as num?)?.toDouble() ?? 0.0,
      temperatureStatus: json['temperatureStatus'] ?? 'Unknown',
      temperatureIndex:
          (json['temperatureHealthIndex'] as num?)?.toDouble() ?? 0.0,
      movementStats:
          (json['movementStats'] as List?)?.map((e) => e.toString()).toList() ??
          [],
    );
  }

  /// Convert JSON to AnalyticsUptimeModel
  AnalyticsUptimeModel uptimeFromJson(Map<String, dynamic> json) {
    return AnalyticsUptimeModel(
      score: (json['score'] as num?)?.toDouble() ?? 0.0,
      expected: json['expectedPackets'] ?? 0,
      received: json['receivedPackets'] ?? 0,
      largestGap: (json['largestGapSec'] as num?)?.toDouble() ?? 0.0,
      dropouts: json['dropouts'] ?? 0,
    );
  }

  /// Convert Distance Model to Entity
  AnalyticsDistanceEntity distanceToEntity(AnalyticsDistanceModel model) {
    return AnalyticsDistanceEntity(
      hour: model.hour,
      distance: model.distance,
      cumulative: model.cumulative,
    );
  }

  /// Convert Health Model to Entity
  AnalyticsHealthEntity healthToEntity(AnalyticsHealthModel model) {
    return AnalyticsHealthEntity(
      gpsScore: model.gpsScore,
      temperatureStatus: model.temperatureStatus,
      temperatureIndex: model.temperatureIndex,
      movementStats: model.movementStats,
    );
  }

  /// Convert Uptime Model to Entity
  AnalyticsUptimeEntity uptimeToEntity(AnalyticsUptimeModel model) {
    return AnalyticsUptimeEntity(
      score: model.score,
      expected: model.expected,
      received: model.received,
      largestGap: model.largestGap,
      dropouts: model.dropouts,
    );
  }
}
