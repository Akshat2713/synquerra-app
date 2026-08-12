import '../../../domain/entities/relationship/relationship_entity.dart';
import '../signup/person_model.dart';

class RelationshipModel {
  final String id;
  final String personAId;
  final String personBId;
  final String relationshipType;
  final String? effectiveFrom;
  final String? effectiveTo;
  final bool isActive;
  final PersonModel? personA;
  final PersonModel? personB;

  const RelationshipModel({
    required this.id,
    required this.personAId,
    required this.personBId,
    required this.relationshipType,
    this.effectiveFrom,
    this.effectiveTo,
    required this.isActive,
    this.personA,
    this.personB,
  });

  factory RelationshipModel.fromJson(Map<String, dynamic> json) =>
      RelationshipModel(
        id: json['id'] as String,
        personAId: json['person_a_id'] as String,
        personBId: json['person_b_id'] as String,
        relationshipType: (json['relationship_type'] as String? ?? '').trim(),
        effectiveFrom: json['effective_from'] as String?,
        effectiveTo: json['effective_to'] as String?,
        isActive: json['is_active'] as bool? ?? true,
        personA: json['person_a'] != null
            ? PersonModel.fromJson(json['person_a'] as Map<String, dynamic>)
            : null,
        personB: json['person_b'] != null
            ? PersonModel.fromJson(json['person_b'] as Map<String, dynamic>)
            : null,
      );

  RelationshipEntity toEntity() => RelationshipEntity(
    id: id,
    personAId: personAId,
    personBId: personBId,
    relationshipType: relationshipType,
    effectiveFrom: effectiveFrom != null
        ? DateTime.tryParse(effectiveFrom!)
        : null,
    effectiveTo: effectiveTo != null ? DateTime.tryParse(effectiveTo!) : null,
    isActive: isActive,
    personA: personA?.toEntity(),
    personB: personB?.toEntity(),
  );
}
