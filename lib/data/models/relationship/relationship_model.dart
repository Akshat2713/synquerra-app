import '../../../domain/entities/relationship/relationship_entity.dart';
import 'related_user_model.dart';

class RelationshipModel {
  final String relatedUserId;
  final String relationshipType;
  final bool isHead;
  final String? createdAt;
  final RelatedUserModel? relatedUser; // ✅ Uses RelatedUserModel

  const RelationshipModel({
    required this.relatedUserId,
    required this.relationshipType,
    required this.isHead,
    this.createdAt,
    this.relatedUser,
  });

  factory RelationshipModel.fromJson(Map<String, dynamic> json) =>
      RelationshipModel(
        relatedUserId: json['related_user_id'] as String? ?? '',
        relationshipType: (json['relationship_type'] as String? ?? '').trim(),
        isHead: json['is_head'] as bool? ?? false,
        createdAt: json['created_at'] as String?,
        relatedUser: json['related_user'] != null
            ? RelatedUserModel.fromJson(
                json['related_user'] as Map<String, dynamic>,
              )
            : null,
      );

  RelationshipEntity toEntity() => RelationshipEntity(
    relatedUserId: relatedUserId,
    relationshipType: relationshipType,
    isHead: isHead,
    createdAt: createdAt != null ? DateTime.tryParse(createdAt!) : null,
    relatedUser: relatedUser?.toEntity(),
  );
}
