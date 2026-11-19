import 'package:equatable/equatable.dart';
import 'geofence_entity.dart';

/// One of the fixed device geofence slots (01, 02, 03).
/// Pure domain model: maps a flat geofence list into a fixed slot layout.
class GeofenceSlot extends Equatable {
  static const int totalSlots = 3;

  /// 1-based slot index.
  final int index;

  /// Geofence occupying this slot, null when the slot is empty.
  final GeofenceEntity? geofence;

  const GeofenceSlot({required this.index, this.geofence});

  /// Slot number in the backend format: "GEO1", "GEO2", "GEO3".
  String get number => 'GEO$index';

  bool get isEmpty => geofence == null;

  /// Builds the fixed slots from all geofences. Only device-synced geofences
  /// whose geofenceNumber parses to 1..totalSlots are placed.
  static List<GeofenceSlot> fromGeofences(List<GeofenceEntity> all) {
    final byIndex = <int, GeofenceEntity>{};

    for (final g in all) {
      if (!g.isSyncToDevice) continue;
      // Backend sends "GEO1".."GEO3" (or null); keep only the digits.
      final n = int.tryParse(g.geofenceNumber.replaceAll(RegExp(r'\D'), ''));
      if (n == null || n < 1 || n > totalSlots) continue;
      byIndex[n] = g;
    }

    return List.generate(
      totalSlots,
      (i) => GeofenceSlot(index: i + 1, geofence: byIndex[i + 1]),
    );
  }

  @override
  List<Object?> get props => [index, geofence];
}
