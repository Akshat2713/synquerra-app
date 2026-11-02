import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/signup/person_entity.dart';
import '../../blocs/profile/profile_bloc.dart';
import '../../themes/app_tokens.dart';
import '../../utils/date_time_formatter.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_overlays.dart';
import '../../widgets/member_form_controller.dart';
import '../../widgets/member_form_fields.dart';

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

  // TODO(logic): empty-string -> null mapping belongs in the bloc/use case.
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
        profileImage: c.profileImageFile,
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
          AppSnackBar.error(context, state.errorMessage!);
          return;
        }

        if (state is ProfileLoaded &&
            !state.isUpdating &&
            state.errorMessage == null) {
          _wasSubmitting = false;
          // Shown on the root messenger, so it carries over to the profile
          // screen after the pop.
          AppSnackBar.success(context, 'Profile updated successfully');
          Navigator.pop(context, true);
        }
      },
      builder: (context, state) {
        final isSaving = state is ProfileLoaded && state.isUpdating;
        return Scaffold(
          appBar: AppBar(title: const Text('Update Profile')),
          body: SafeArea(
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: AppSpacing.lg,
                  children: [
                    MemberFormFields(
                      controller: _controller,
                      requirePassword: false,
                      showRelationshipFields: false,
                    ),
                    AppButton(
                      label: 'Save Changes',
                      onPressed: _submit,
                      isLoading: isSaving,
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
