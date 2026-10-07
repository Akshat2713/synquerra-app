import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/manage_users/manage_users_bloc.dart';
import '../../themes/colors.dart';
import '../../widgets/app_button.dart';
import '../../widgets/member_form_controller.dart';
import '../../widgets/member_form_fields.dart';
import '../../utils/date_time_formatter.dart';
import 'package:synquerra/presentation/themes/app_tokens.dart';

class AddMemberScreen extends StatefulWidget {
  const AddMemberScreen({super.key});

  @override
  State<AddMemberScreen> createState() => _AddMemberScreenState();
}

class _AddMemberScreenState extends State<AddMemberScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _controller = MemberFormController();

  // Tracks whether the in-flight submission belongs to this screen, so the
  // listener doesn't react to isAdding changes triggered elsewhere.
  bool _wasSubmitting = false;
  bool _awaitingReload = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    _wasSubmitting = true;
    _awaitingReload = false;
    final c = _controller;
    context.read<ManageUsersBloc>().add(
      ManageUsersAddRequested(
        firstName: c.firstNameController.text.trim(),
        middleName: c.middleNameController.text.trim().isEmpty
            ? null
            : c.middleNameController.text.trim(),
        lastName: c.lastNameController.text.trim(),
        email: c.emailController.text.trim(),
        password: c.passwordController.text,
        mobile: c.phoneController.text.trim(),
        birthDate: c.birthDate != null
            ? DateTimeFormatter.toIsoString(c.birthDate!)
            : '',
        gender: c.gender,
        address: c.addressController.text.trim(),
        city: c.cityController.text.trim(),
        state: c.stateController.text.trim(),
        country: c.countryController.text.trim(),
        pincode: c.pincodeController.text.trim(),
        relationshipType: c.relationshipType,
        isHead: c.isHead,
        profileImage: c.profileImageFile,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ManageUsersBloc, ManageUsersState>(
      listener: (context, state) {
        if (!_wasSubmitting) return;

        if (state is ManageUsersLoaded && state.errorMessage != null) {
          // Add or relationship-create failed.
          _wasSubmitting = false;
          _awaitingReload = false;
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

        if (state is ManageUsersLoading) {
          // The bloc succeeded and is now re-fetching the list.
          _awaitingReload = true;
          return;
        }

        if (state is ManageUsersLoaded && _awaitingReload) {
          // Reload after a successful add completed.
          _wasSubmitting = false;
          _awaitingReload = false;
          Navigator.pop(context, true);
        }
      },
      builder: (context, state) {
        final isAdding =
            _wasSubmitting &&
            (state is ManageUsersLoading ||
                (state is ManageUsersLoaded && state.isProcessing));
        return Scaffold(
          appBar: AppBar(
            title: const Text('Add Family Member'),
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
                      requirePassword: true,
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
                            label: 'Add Member',
                            onPressed: _submit,
                            isLoading: isAdding,
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
