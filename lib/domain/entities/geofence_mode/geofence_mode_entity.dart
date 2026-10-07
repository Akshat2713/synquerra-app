import 'package:equatable/equatable.dart';

class GeofenceModeEntity extends Equatable {
  final String id;
  final String name;
  final List<String> categories;
  final String? description;

  const GeofenceModeEntity({
    required this.id,
    required this.name,
    this.categories = const [],
    this.description,
  });

  bool get isGeofence => categories.contains('geofence');
  bool get isAuto => categories.contains('auto');
  String get displayDescription => (description?.trim().isNotEmpty ?? false)
      ? description!
      : 'No description available';

  @override
  List<Object?> get props => [id, name, categories];
}

extension GeofenceModeFiltering on List<GeofenceModeEntity> {
  List<GeofenceModeEntity> get autoModes => where((m) => m.isAuto).toList();

  List<GeofenceModeEntity> get geofenceModes =>
      where((m) => m.isGeofence).toList();
}
