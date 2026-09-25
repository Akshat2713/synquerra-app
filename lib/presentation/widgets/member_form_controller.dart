import 'dart:io';
import 'package:flutter/material.dart';
import '../../domain/entities/signup/person_entity.dart';
import '../utils/date_time_formatter.dart';

/// Holds every controller + value used by [MemberFormFields].
///
/// Create one instance per screen (Add / Update), pass it to the widget,
/// and read the values back out of it when the user submits. Call
/// [dispose] in the screen's `dispose()`.
class MemberFormController {
  final firstNameController = TextEditingController();
  final middleNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();
  final birthDateController = TextEditingController();
  final addressController = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final countryController = TextEditingController();
  final pincodeController = TextEditingController();

  String gender;
  DateTime? birthDate;

  /// Add-member only. Update screen doesn't set/send these — the field
  /// still lives here since MemberFormFields is shared, but pass
  /// showRelationshipFields: false on the Update screen to hide them.
  String relationshipType;
  bool isHead;

  /// Single source of truth for the avatar: either the existing server URL
  /// (e.g. "https://...s3.../profile/xyz.jpg") kept as-is until the user
  /// picks a new photo, or a local file path once they do. Null means no
  /// photo at all.
  String? profilePhoto;

  MemberFormController({
    PersonEntity? person,
    String? relationshipType,
    bool isHead = false,
  }) : gender = person?.gender ?? 'male',
       relationshipType = relationshipType ?? 'child',
       isHead = isHead,
       birthDate = person?.birthDate,
       profilePhoto = person?.profilePhoto {
    if (person != null) {
      firstNameController.text = person.firstName;
      middleNameController.text = person.middleName ?? '';
      lastNameController.text = person.lastName;
      emailController.text = person.email ?? '';
      phoneController.text = person.phone ?? person.mobile ?? '';
      addressController.text = person.address ?? '';
      cityController.text = person.city ?? '';
      stateController.text = person.state ?? '';
      countryController.text = person.country ?? '';
      pincodeController.text = person.pincode ?? '';
      if (person.birthDate != null) {
        birthDateController.text = DateTimeFormatter.formatDate(
          person.birthDate!,
        );
      }
    }
  }

  static bool _isNetworkPath(String path) =>
      path.startsWith('http://') || path.startsWith('https://');

  /// True once the user has picked a new photo this session — i.e.
  /// profilePhoto now holds a local file path rather than the original URL.
  bool get profilePhotoChanged =>
      profilePhoto != null &&
      profilePhoto!.isNotEmpty &&
      !_isNetworkPath(profilePhoto!);

  /// The File to send to the add/update usecase, or null if there's
  /// nothing new to upload (still the original URL, or no photo at all).
  File? get profileImageFile =>
      profilePhotoChanged ? File(profilePhoto!) : null;

  /// What the avatar widget should render — network vs local vs placeholder,
  /// decided here so MemberFormFields doesn't need to know the difference.
  ImageProvider? get avatarImage {
    final p = profilePhoto;
    if (p == null || p.isEmpty) return null;
    return _isNetworkPath(p) ? NetworkImage(p) : FileImage(File(p));
  }

  void dispose() {
    firstNameController.dispose();
    middleNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    phoneController.dispose();
    birthDateController.dispose();
    addressController.dispose();
    cityController.dispose();
    stateController.dispose();
    countryController.dispose();
    pincodeController.dispose();
  }
}
