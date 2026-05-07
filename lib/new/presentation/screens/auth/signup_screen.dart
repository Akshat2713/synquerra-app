// lib/presentation/screens/auth/signup_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:synquerra/new/business/blocs/auth_bloc/auth_bloc.dart';
import 'package:synquerra/new/business/entities/signup_input_entity.dart';
import 'package:synquerra/new/di/injection_container.dart' as di;
import 'package:synquerra/new/presentation/themes/colors.dart';
import 'package:synquerra/new/presentation/widgets/auth/auth_footer.dart';
import 'package:synquerra/new/presentation/widgets/auth/auth_header.dart';
import 'package:synquerra/new/presentation/widgets/buttons/loading_button.dart';
import 'package:synquerra/new/presentation/widgets/feedback/custom_snackbar.dart';
import 'package:synquerra/new/presentation/widgets/forms/custom_text_field.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: di.sl<AuthBloc>(),
      child: const SignupView(),
    );
  }
}

class SignupView extends StatefulWidget {
  const SignupView({super.key});

  @override
  State<SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends State<SignupView> with TickerProviderStateMixin {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  int _currentStep = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0.1, 0), end: Offset.zero).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );
    _animationController.forward();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 2) {
      setState(() => _currentStep++);
      _animationController.reset();
      _animationController.forward();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _animationController.reset();
      _animationController.forward();
    }
  }

  void _handleSignup() {
    final input = SignupInputEntity(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      email: _emailController.text.trim(),
      mobile: _mobileController.text.trim(),
      password: _passwordController.text,
      middleName: null,
    );

    context.read<AuthBloc>().add(AuthSignupRequested(input: input));
  }

  Widget _buildStepIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: _currentStep == index ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: _currentStep >= index
                ? AppColors.safeGreen
                : Colors.grey.withOpacity(0.3),
          ),
        );
      }),
    );
  }

  Widget _buildStep1() {
    return Column(
      children: [
        CustomTextField(
          controller: _firstNameController,
          label: 'First Name',
          icon: Icons.person_outline_rounded,
        ),
        const SizedBox(height: 20),
        CustomTextField(
          controller: _lastNameController,
          label: 'Last Name',
          icon: Icons.person_outline_rounded,
        ),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      children: [
        CustomTextField(
          controller: _emailController,
          label: 'Email Address',
          icon: Icons.email_outlined,
          inputType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 20),
        CustomTextField(
          controller: _mobileController,
          label: 'Mobile Number',
          icon: Icons.phone_android_rounded,
          inputType: TextInputType.phone,
        ),
      ],
    );
  }

  Widget _buildStep3() {
    return Column(
      children: [
        CustomTextField(
          controller: _passwordController,
          label: 'Password',
          icon: Icons.lock_outline_rounded,
          isPassword: true,
        ),
        const SizedBox(height: 20),
        CustomTextField(
          controller: _confirmPasswordController,
          label: 'Confirm Password',
          icon: Icons.lock_outline_rounded,
          isPassword: true,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isLoading = context.watch<AuthBloc>().state is AuthLoading;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Register"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.arrow_back_rounded,
              color: colorScheme.onSurface,
              size: 20,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            CustomSnackbar.show(
              context,
              message: 'Account created successfully!',
              type: SnackbarType.success,
            );
            Navigator.pushReplacementNamed(context, '/map');
          } else if (state is AuthError) {
            CustomSnackbar.show(
              context,
              message: state.message,
              type: SnackbarType.error,
            );
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
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
                    height: 80,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.school_rounded,
                      size: 60,
                      color: AppColors.safeGreen,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Header
                AuthHeader(
                  title: "Join Synquerra",
                  subtitle: "Create an account to start tracking",
                ),
                const SizedBox(height: 32),

                // Step Indicator
                _buildStepIndicator(),
                const SizedBox(height: 32),

                // Form with Animation
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Container(
                      child: Column(
                        children: [
                          if (_currentStep == 0) _buildStep1(),
                          if (_currentStep == 1) _buildStep2(),
                          if (_currentStep == 2) _buildStep3(),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Navigation Buttons
                Row(
                  children: [
                    if (_currentStep > 0)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _previousStep,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text("Back"),
                        ),
                      ),
                    if (_currentStep > 0) const SizedBox(width: 12),
                    Expanded(
                      child: _currentStep < 2
                          ? ElevatedButton(
                              onPressed: _nextStep,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.navBlue,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: const Text("Next"),
                            )
                          : LoadingButton(
                              onPressed: _handleSignup,
                              isLoading: isLoading,
                              label: "Create Account",
                              backgroundColor: AppColors.safeGreen,
                              icon: Icons.check_rounded,
                              fullWidth: true,
                            ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Login Link
                AuthFooter(
                  question: "Already have an account?",
                  actionLabel: "Sign In",
                  onActionTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
