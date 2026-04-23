// lib/presentation/screens/auth/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../business/blocs/auth_bloc/auth_bloc.dart';
import '../../widgets/auth/auth_header.dart';
import '../../widgets/auth/auth_footer.dart';
import '../../widgets/buttons/loading_button.dart';
import '../../widgets/forms/custom_text_field.dart';
import '../../widgets/feedback/custom_snackbar.dart';
import '../../themes/colors.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const LoginView();
  }
}

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      CustomSnackbar.show(
        context,
        message: 'Please enter both email and password',
        type: SnackbarType.error,
      );
      return;
    }

    // Add debug print
    debugPrint('Attempting login with email: $email');

    context.read<AuthBloc>().add(
      AuthLoginRequested(email: email, password: password),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          debugPrint('AuthState changed: $state'); // Add debug print

          if (state is AuthAuthenticated) {
            debugPrint('Login successful, navigating to map');
            Navigator.pushReplacementNamed(context, '/map');
          } else if (state is AuthError) {
            debugPrint('Login error: ${state.message}'); // Add debug print
            CustomSnackbar.show(
              context,
              message: state.message,
              type: SnackbarType.error,
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colorScheme.primary.withOpacity(0.1),
                    ),
                    child: Image.asset(
                      'assets/images/app_logo.png',
                      height: 100,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.school_rounded,
                        size: 80,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Header
                  AuthHeader(
                    title: 'Welcome Back!',
                    subtitle: 'Sign in to continue to Synquerra',
                  ),
                  const SizedBox(height: 40),

                  // Email Field
                  CustomTextField(
                    controller: _emailController,
                    label: 'Email',
                    icon: Icons.email_outlined,
                    inputType: TextInputType.emailAddress,
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: 20),

                  // Password Field
                  CustomTextField(
                    controller: _passwordController,
                    label: 'Password',
                    icon: Icons.lock_outline,
                    isPassword: true,
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: 8),

                  // Forgot Password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              CustomSnackbar.show(
                                context,
                                message:
                                    'Password reset link sent to your email',
                                type: SnackbarType.info,
                              );
                            },
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Login Button
                  LoadingButton(
                    onPressed: _handleLogin,
                    isLoading: isLoading,
                    label: 'Sign In',
                    backgroundColor: colorScheme.primary,
                    fullWidth: true,
                  ),
                  const SizedBox(height: 30),

                  // Sign Up Link
                  AuthFooter(
                    question: "Don't have an account?",
                    actionLabel: "Sign Up",
                    onActionTap: () {
                      debugPrint('Navigating to signup'); // Add debug print
                      Navigator.pushNamed(context, '/signup');
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
