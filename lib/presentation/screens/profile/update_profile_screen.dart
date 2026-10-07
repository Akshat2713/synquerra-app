import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/signup/person_entity.dart';
import '../../blocs/profile/profile_bloc.dart';
import '../../themes/colors.dart';
import '../../widgets/app_button.dart';
import '../../widgets/member_form_controller.dart';
import '../../widgets/member_form_fields.dart';
import '../../utils/date_time_formatter.dart';
import 'package:synquerra/presentation/themes/app_tokens.dart';

class UpdateProfileScreen extends StatefulWidget {
  /// Existing values to pre-fill the form with, including
  /// `profilePhotoUrl` (the S3 URL from the loaded profile).
  final PersonEntity person;

  const UpdateProfileScreen({super.key, required this.person});

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _controller = MemberFormController(person: widget.person);

  bool _wasSubmitting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    _wasSubmitting = true;
    final c = _controller;
    context.read<ProfileBloc>().add(
      UpdateUserProfile(
        firstName: c.firstNameController.text.trim(),
        lastName: c.lastNameController.text.trim(),
        email: c.emailController.text.trim(),
        password: c.passwordController.text.isEmpty
            ? null
            : c.passwordController.text,
        middleName: c.middleNameController.text.trim().isEmpty
            ? null
            : c.middleNameController.text.trim(),
        mobile: c.phoneController.text.trim(),
        birthDate: c.birthDate != null
            ? DateTimeFormatter.toIsoString(c.birthDate!)
            : null,
        gender: c.gender,
        address: c.addressController.text.trim(),
        city: c.cityController.text.trim(),
        state: c.stateController.text.trim(),
        country: c.countryController.text.trim(),
        pincode: c.pincodeController.text.trim(),
        profileImage: c
            .profileImageFile, // was: c.profilePhotoChanged ? c.newProfileImage : null
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (!_wasSubmitting) return;

        if (state is ProfileLoaded && state.errorMessage != null) {
          _wasSubmitting = false;
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: AppColors.danger,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.mdAll,
                ),
              ),
            );
          return;
        }

        if (state is ProfileLoaded &&
            !state.isUpdating &&
            state.errorMessage == null) {
          // Save completed successfully.
          _wasSubmitting = false;
          Navigator.pop(context, true);
        }
      },
      builder: (context, state) {
        final isSaving = state is ProfileLoaded && state.isUpdating;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Update Profile'),
            centerTitle: false,
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MemberFormFields(
                      controller: _controller,
                      requirePassword: false,
                      showRelationshipFields: false,
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              color: AppColors.textSecondary(context),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 200,
                          child: AppButton(
                            label: 'Save Changes',
                            onPressed: _submit,
                            isLoading: isSaving,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
