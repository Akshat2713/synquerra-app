import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../app/app_router.dart';
import '../../blocs/signup/signup_bloc.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/app_button.dart';
import '../../widgets/signup_progress_tracker.dart';

class SignupPasswordSetupScreen extends StatefulWidget {
  const SignupPasswordSetupScreen({super.key});

  @override
  State<SignupPasswordSetupScreen> createState() =>
      _SignupPasswordSetupScreenState();
}

class _SignupPasswordSetupScreenState extends State<SignupPasswordSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _useSameEmail = true;
  String _profileEmail = ''; // holds email from bloc state

  @override
  void initState() {
    super.initState();
    // Read email from bloc state — no constructor param needed
    _profileEmail = context.read<SignupBloc>().state.email ?? '';
    _emailController.text = _profileEmail;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onCheckboxChanged(bool? value) {
    if (value == null) return;
    setState(() {
      _useSameEmail = value;
      if (_useSameEmail) {
        _emailController.text = _profileEmail; // restore profile email
      } else {
        _emailController.clear(); // let user type new one
      }
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<SignupBloc>().add(
      SignupCredentialsSubmitted(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        passwordConfirmation: _confirmPasswordController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return BlocListener<SignupBloc, SignupState>(
      listener: (context, state) {
        // Navigate to screen 3 when step 2 succeeds
        if (state.status == SignupStatus.stepSuccess && state.step == 3) {
          Navigator.pushNamed(context, AppRoutes.signupDevice);
        }

        // Show error snackbar
        if (state.status == SignupStatus.error && state.errorMessage != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: colors.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
        }
      },
      child: Scaffold(
        backgroundColor: colors.surface,
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
                      color: colors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Configure your system sign-in credentials.',
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ── Progress Tracker ─────────────────────────
                  const SignupProgressTracker(currentStep: SignupStep.device),
                  const SizedBox(height: 36),

                  // ── Checkbox ─────────────────────────────────
                  CheckboxListTile(
                    title: const Text(
                      'Use same email as registered in profile details',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    value: _useSameEmail,
                    onChanged: _onCheckboxChanged,
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    activeColor: colors.primary,
                  ),
                  const SizedBox(height: 12),

                  // ── Email ─────────────────────────────────────
                  AppTextField(
                    controller: _emailController,
                    label: 'Account Email *',
                    hint: 'you@example.com',
                    readOnly: _useSameEmail,
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Email is required';
                      }
                      if (!v.contains('@'))
                        return 'Enter a valid email address';
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
                          context.read<SignupBloc>().add(
                            const SignupStepBack(),
                          );
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Back',
                          style: TextStyle(color: colors.onSurfaceVariant),
                        ),
                      ),
                      BlocBuilder<SignupBloc, SignupState>(
                        builder: (context, state) {
                          return SizedBox(
                            width: 200,
                            child: AppButton(
                              label: 'Next: Link Device',
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
