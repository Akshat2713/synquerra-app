import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/signup/signup_profile_data.dart';
import '../../app/app_router.dart';
import '../../blocs/signup/signup_bloc.dart';
import '../../themes/colors.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/app_button.dart';
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
    if (!_formKey.currentState!.validate()) return;
    final p = widget.profileData;
    context.read<SignupBloc>().add(
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

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return BlocListener<SignupBloc, SignupState>(
      listener: (context, state) {
        // Navigate to screen 3 when step 2 succeeds
        if (state.status == SignupStatus.done) {
          Navigator.pushNamed(context, AppRoutes.login);
        }

        // Show error snackbar
        if (state.status == SignupStatus.error && state.errorMessage != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: AppColors.danger,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // ── Page Header ──────────────────────────────
                  Text(
                    'Secure Your Account',
                    style: textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary(context),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Configure your system sign-in credentials.',
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary(context),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ── Progress Tracker ─────────────────────────
                  const SignupProgressTracker(currentStep: SignupStep.security),
                  const SizedBox(height: 36),

                  // ── Checkbox ─────────────────────────────────
                  // ── Email ─────────────────────────────────────
                  AppTextField(
                    controller: _emailController,
                    label: 'Account Email *',
                    hint: 'you@example.com',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    readOnly: true,
                    enabled: false,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Email is required';
                      }
                      if (!v.contains('@')) {
                        return 'Enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // ── Password ──────────────────────────────────
                  AppTextField(
                    controller: _passwordController,
                    label: 'Set Password *',
                    hint: '••••••••',
                    prefixIcon: Icons.lock_outline_rounded,
                    isPassword: true,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Password is required';
                      if (v.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // ── Confirm Password ──────────────────────────
                  AppTextField(
                    controller: _confirmPasswordController,
                    label: 'Confirm Password *',
                    hint: '••••••••',
                    prefixIcon: Icons.lock_reset_rounded,
                    isPassword: true,
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (v != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 36),

                  // ── Footer ────────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Back',
                          style: TextStyle(
                            color: AppColors.textSecondary(context),
                          ),
                        ),
                      ),
                      BlocBuilder<SignupBloc, SignupState>(
                        builder: (context, state) {
                          return SizedBox(
                            width: 200,
                            child: AppButton(
                              label: 'Submit',
                              onPressed: _submit,
                              isLoading: state.status == SignupStatus.loading,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
