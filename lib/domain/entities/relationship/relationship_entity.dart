import 'package:equatable/equatable.dart';
import 'related_user_entity.dart';

enum RelationType { child, parent, teacher, guardian, spouse, other }

class RelationshipEntity extends Equatable {
  final String relatedUserId;
  final String relationshipType;
  final bool isHead;
  final DateTime? createdAt;
  final RelatedUserEntity? relatedUser;
  const RelationshipEntity({
    required this.relatedUserId,
    required this.relationshipType,
    required this.isHead,
    this.createdAt,
    this.relatedUser,
  });

  @override
  List<Object?> get props => [
    relatedUserId,
    relationshipType,
    isHead,
    createdAt,
    relatedUser,
  ];
}
