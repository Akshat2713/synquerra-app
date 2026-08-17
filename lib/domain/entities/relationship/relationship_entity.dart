import 'package:equatable/equatable.dart';

import '../signup/person_entity.dart';

enum relationtype { child, parent }

class RelationshipEntity extends Equatable {
  final String id;
  final String personAId;
  final String personBId;
  final String relationshipType;
  final DateTime? effectiveFrom;
  final DateTime? effectiveTo;
  final bool isActive;
  final PersonEntity? personA;
  final PersonEntity? personB;

  const RelationshipEntity({
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

  @override
  List<Object?> get props => [
    id,
    personAId,
    personBId,
    relationshipType,
    effectiveFrom,
    effectiveTo,
    isActive,
    personA,
    personB,
  ];
}
