import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/signup/signup_profile_data.dart';
import '../../app/app_router.dart';
import '../../blocs/signup/signup_bloc.dart';
import '../../themes/app_text_styles.dart';
import '../../themes/app_tokens.dart';
import '../../themes/colors.dart';
import '../../utils/app_icons.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_motion_widgets.dart';
import '../../widgets/app_overlays.dart';
import '../../widgets/app_section_card.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/signup_progress_tracker.dart';

class SignupPasswordSetupScreen extends StatefulWidget {
  final SignupProfileData profileData;
  const SignupPasswordSetupScreen({super.key, required this.profileData});

  @override
  State<SignupPasswordSetupScreen> createState() =>
      _SignupPasswordSetupScreenState();
}

class _SignupPasswordSetupScreenState extends State<SignupPasswordSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _emailController.text = widget.profileData.email;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() {
    final bloc = context.read<SignupBloc>();
    // Keyboard "done" bypasses the button's loading guard.
    if (bloc.state.status == SignupStatus.loading) return;
    if (!_formKey.currentState!.validate()) return;
    final p = widget.profileData;
    bloc.add(
      SignupSubmitted(
        firstName: p.firstName,
        lastName: p.lastName,
        email: _emailController.text.trim(),
        password: _passwordController.text,
        phone: p.phone,
        birthDate: p.birthDate,
        gender: p.gender,
        address: p.address,
        city: p.city,
        state: p.state,
        country: p.country,
        pincode: p.pincode,
      ),
    );
  }

  // TODO(logic): move to a shared validators util (min length 6, match check).
  String? _validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'Password is required';
    if (v.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  String? _validateConfirm(String? v) {
    if (v == null || v.isEmpty) return 'Please confirm your password';
    if (v != _passwordController.text) return 'Passwords do not match';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SignupBloc, SignupState>(
      listener: (context, state) {
        if (state.status == SignupStatus.done) {
          AppSnackBar.success(context, 'Account created. Please sign in.');
          Navigator.pushNamed(context, AppRoutes.login);
        }
        if (state.status == SignupStatus.error && state.errorMessage != null) {
          AppSnackBar.error(context, state.errorMessage!);
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Secure Your Account')),
        body: SafeArea(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: AppSpacing.mdAll,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: AppSpacing.md,
                children: [
                  Text(
                    'Configure your system sign-in credentials.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyWithColor(context),
                  ).entrance(context, index: 0),

                  const SignupProgressTracker(
                    currentStep: SignupStep.security,
                  ).entrance(context, index: 1),

                  AppSectionCard(
                    title: 'Account',
                    icon: AppIcons.lock,
                    background: AppColors.success,
                    foreground: AppColors.onSuccess,
                    children: [
                      AppTextField(
                        controller: _emailController,
                        label: 'Account Email',
                        prefixIcon: AppIcons.email,
                        keyboardType: TextInputType.emailAddress,
                        readOnly: true,
                        enabled: false,
                      ),
                      AppTextField(
                        controller: _passwordController,
                        label: 'Set Password *',
                        hint: '••••••••',
                        prefixIcon: AppIcons.lock,
                        isPassword: true,
                        validator: _validatePassword,
                      ),
                      AppTextField(
                        controller: _confirmPasswordController,
                        label: 'Confirm Password *',
                        hint: '••••••••',
                        prefixIcon: AppIcons.lock,
                        isPassword: true,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _submit(),
                        validator: _validateConfirm,
                      ),
                    ],
                  ).entrance(context, index: 2),

                  const SizedBox(height: AppSpacing.xs),
                  BlocBuilder<SignupBloc, SignupState>(
                    builder: (context, state) => AppButton(
                      label: 'Submit',
                      onPressed: _submit,
                      isLoading: state.status == SignupStatus.loading,
                    ),
                  ).entrance(context, index: 3),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
