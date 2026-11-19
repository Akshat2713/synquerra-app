import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/manage_users/manage_users_bloc.dart';
import '../../themes/app_tokens.dart';
import '../../utils/date_time_formatter.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_overlays.dart';
import '../../widgets/member_form_controller.dart';
import '../../widgets/member_form_fields.dart';

class AddMemberScreen extends StatefulWidget {
  const AddMemberScreen({super.key});

  @override
  State<AddMemberScreen> createState() => _AddMemberScreenState();
}

class _AddMemberScreenState extends State<AddMemberScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _controller = MemberFormController();

  // TODO(logic): the submit/reload tracking below should live in the bloc
  // (a dedicated "added" state) instead of these two flags.
  bool _wasSubmitting = false;
  bool _awaitingReload = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // TODO(logic): empty-string -> null mapping belongs in the bloc/use case.
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
          _wasSubmitting = false;
          _awaitingReload = false;
          AppSnackBar.error(context, state.errorMessage!);
          return;
        }

        if (state is ManageUsersLoading) {
          _awaitingReload = true;
          return;
        }

        if (state is ManageUsersLoaded && _awaitingReload) {
          _wasSubmitting = false;
          _awaitingReload = false;
          AppSnackBar.success(context, 'Member added successfully');
          Navigator.pop(context, true);
        }
      },
      builder: (context, state) {
        final isAdding =
            _wasSubmitting &&
            (state is ManageUsersLoading ||
                (state is ManageUsersLoaded && state.isProcessing));
        return Scaffold(
          appBar: AppBar(title: const Text('Add Family Member')),
          body: SafeArea(
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: AppSpacing.mdAll,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: AppSpacing.lg,
                  children: [
                    MemberFormFields(
                      controller: _controller,
                      requirePassword: true,
                    ),
                    AppButton(
                      label: 'Add Member',
                      onPressed: _submit,
                      isLoading: isAdding,
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
