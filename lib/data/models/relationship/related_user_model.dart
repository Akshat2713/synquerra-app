import '../../../domain/entities/relationship/related_user_entity.dart';

class RelatedUserModel {
  final String id;
  final String uniqueId;
  final String firstName;
  final String lastName;
  final String? email;
  final String? mobile;
  final String? profilePhoto;

  const RelatedUserModel({
    required this.id,
    required this.uniqueId,
    required this.firstName,
    required this.lastName,
    this.email,
    this.mobile,
    this.profilePhoto,
  });

  factory RelatedUserModel.fromJson(Map<String, dynamic> json) =>
      RelatedUserModel(
        id: json['id'] as String? ?? '',
        uniqueId: json['unique_id'] as String? ?? '',
        firstName: (json['first_name'] as String? ?? '').trim(),
        lastName: (json['last_name'] as String? ?? '').trim(),
        email: json['email'] as String?,
        mobile: json['mobile'] as String?,
        profilePhoto: json['profile_photo'] as String?,
      );

  RelatedUserEntity toEntity() => RelatedUserEntity(
    id: id,
    uniqueId: uniqueId,
    firstName: firstName,
    lastName: lastName,
    email: email,
    mobile: mobile,
    profilePhoto: profilePhoto,
  );
}
