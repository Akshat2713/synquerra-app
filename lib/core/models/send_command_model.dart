class CommandResponse {
  final String status;
  final String note;
  final String imei;
  final String command;
  final int qos;
  final DateTime createdAt;

  CommandResponse({
    required this.status,
    required this.note,
    required this.imei,
    required this.command,
    required this.qos,
    required this.createdAt,
  });

  factory CommandResponse.fromJson(Map<String, dynamic> json) {
    return CommandResponse(
      status: json['status'] ?? 'FAILED',
      note: json['note'] ?? '',
      imei: json['imei'] ?? '',
      command: json['command'] ?? '',
      qos: json['qos'] ?? 0,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }
}
