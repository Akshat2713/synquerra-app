import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../app/app_router.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../themes/app_text_styles.dart';
import '../../themes/app_tokens.dart';
import '../../themes/colors.dart';
import '../../utils/app_icons.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_motion_widgets.dart';
import '../../widgets/app_overlays.dart';
import '../../widgets/app_surfaces.dart';
import '../../widgets/app_text_field.dart';
import '../../../core/utils/app_logger.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    final bloc = context.read<AuthBloc>();
    // Keyboard "done" bypasses the button's loading guard.
    if (bloc.state is AuthLoading) return;
    if (!_formKey.currentState!.validate()) return;
    bloc.add(
      AuthLoginRequested(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      ),
    );
  }

  // TODO(logic): move to a shared validators util (email format, min length 6).
  String? _validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email is required.';
    if (!v.contains('@')) return 'Enter a valid email.';
    return null;
  }

  String? _validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'Password is required.';
    if (v.length < 6) return 'Password is too short.';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    // final primary = AppColors.primary(context);

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        AppLogger.d('LoginScreen', 'state changed → $state');
        if (state is AuthAuthenticated) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.deviceList,
            (route) => false,
          );
        } else if (state is AuthError) {
          AppSnackBar.error(context, state.message);
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: AppSpacing.mdAll,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Brand + heading ────────────────────────
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Image.asset(
                            'assets/images/app_logo.png',
                            width: AppSize.authLogo,
                            height: AppSize.authLogo,
                            fit: BoxFit.contain,
                            semanticLabel: 'Synquerra logo',
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          'Welcome!',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.displayWithColor(context),
                        ),
                      ],
                    ).entrance(context, index: 0),
                    const SizedBox(height: AppSpacing.lg),

                    // ── Fields card ────────────────────────────
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AppCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Sign In',
                                textAlign: TextAlign.start,
                                style: AppTextStyles.titleWithColor(context),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              AppTextField(
                                controller: _emailController,
                                label: 'Email',
                                hint: 'Enter your email',
                                prefixIcon: AppIcons.email,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                validator: _validateEmail,
                              ),
                              const SizedBox(height: AppSpacing.md),
                              AppTextField(
                                controller: _passwordController,
                                label: 'Password',
                                prefixIcon: AppIcons.lock,
                                isPassword: true,
                                textInputAction: TextInputAction.done,
                                onSubmitted: (_) => _submit(),
                                validator: _validatePassword,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Align(
                          alignment: Alignment.centerRight,
                          child: _TextLink(
                            label: 'Forgot password?',
                            onTap: () {
                              // TODO: navigate to forgot password
                            },
                          ),
                        ),
                      ],
                    ).entrance(context, index: 1),
                    const SizedBox(height: AppSpacing.lg),

                    // ── Sign in ────────────────────────────────
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) => AppButton(
                        label: 'Sign In',
                        onPressed: _submit,
                        isLoading: state is AuthLoading,
                      ),
                    ).entrance(context, index: 2),
                    const SizedBox(height: AppSpacing.lg),

                    // ── Sign up link ───────────────────────────
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          "Don't have an account?",
                          style: AppTextStyles.bodyWithColor(context),
                        ),
                        _TextLink(
                          label: 'Sign Up',
                          onTap: () => AppRouter.navigateToSignup(context),
                        ),
                      ],
                    ).entrance(context, index: 3),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TextLink extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _TextLink({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primary(context);
    return Semantics(
      button: true,
      child: Material(
        type: MaterialType.transparency,
        borderRadius: AppRadius.smAll,
        child: InkWell(
          borderRadius: AppRadius.smAll,
          onTap: () {
            HapticFeedback.selectionClick();
            onTap();
          },
          child: Padding(
            padding: AppSpacing.smSymmetric,
            child: Text(
              label,
              style: AppTextStyles.bodyWithColor(context, color: primary)
                  .copyWith(
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                    decorationColor: primary,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}
