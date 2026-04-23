// lib/data/models/send_command_model.dart
import 'package:equatable/equatable.dart';

class CommandResponseModel extends Equatable {
  final String status;
  final String note;
  final String imei;
  final String command;
  final int qos;
  final DateTime createdAt;

  const CommandResponseModel({
    required this.status,
    required this.note,
    required this.imei,
    required this.command,
    required this.qos,
    required this.createdAt,
  });

  factory CommandResponseModel.fromJson(Map<String, dynamic> json) {
    return CommandResponseModel(
      status: json['status'] ?? 'FAILED',
      note: json['note'] ?? '',
      imei: json['imei'] ?? '',
      command: json['command'] ?? '',
      qos: json['qos'] ?? 0,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  bool get isSuccess =>
      status.toUpperCase() == 'SENT' || status.toUpperCase() == 'SUCCESS';

  @override
  List<Object?> get props => [status, note, imei, command, qos, createdAt];
}
