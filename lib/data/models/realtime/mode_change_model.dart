import '../../../domain/entities/realtime/device_event.dart';

class ModeChangeModel {
  final String imei;
  final String deviceId;
  final String modeId;
  final String modeName;

  const ModeChangeModel({
    required this.imei,
    required this.deviceId,
    required this.modeId,
    required this.modeName,
  });

  factory ModeChangeModel.fromJson(Map<String, dynamic> json) {
    final mode = json['mode'] as Map<String, dynamic>?;
    return ModeChangeModel(
      imei: json['imei'] as String? ?? '',
      deviceId: json['device_id'] as String? ?? '',
      modeId: json['mode_id'] as String? ?? mode?['id'] as String? ?? '',
      modeName:
          json['mode_name'] as String? ?? mode?['name'] as String? ?? 'Unknown',
    );
  }

  ModeChanged toEvent() => ModeChanged(
    imei: imei,
    deviceId: deviceId,
    modeId: modeId,
    modeName: modeName,
  );
}
