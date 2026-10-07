import '../../../domain/entities/geofence_mode/geofence_mode_entity.dart';

class GeofenceModeModel {
  final String id;
  final String name;
  final List<String> categories;
  final String? description;

  const GeofenceModeModel({
    required this.id,
    required this.name,
    this.categories = const [],
    this.description,
  });

  factory GeofenceModeModel.fromJson(Map<String, dynamic> json) {
    final categoriesJson = json['categories'] as List<dynamic>? ?? [];

    return GeofenceModeModel(
      id: (json['id'] ?? '') as String,
      name: (json['name'] ?? '') as String,
      categories: categoriesJson.map((c) => c.toString()).toList(),
      description: json['description'] as String?,
    );
  }

  /// Parses the full API response: { data: { modes: [...] } }
  static List<GeofenceModeModel> listFromResponse(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    final modes = data['modes'] as List<dynamic>? ?? [];
    return modes
        .map((m) => GeofenceModeModel.fromJson(m as Map<String, dynamic>))
        .toList();
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'categories': categories,
  };

  GeofenceModeEntity toEntity() => GeofenceModeEntity(
    id: id,
    name: name,
    categories: categories,
    description: description,
  );
}
