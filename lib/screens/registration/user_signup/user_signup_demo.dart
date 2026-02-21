import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:synquerra/core/models/signup_input.dart';
import 'package:synquerra/core/services/auth_service.dart';
import 'package:synquerra/screens/registration/login_page.dart';
import 'package:synquerra/theme/colors.dart';
import 'package:synquerra/widgets/custom_text_field.dart';
import 'package:synquerra/widgets/loading_button.dart';
import 'package:synquerra/widgets/auth_header.dart';
import 'package:synquerra/widgets/auth_footer.dart';

class SignupScreenDemo extends StatefulWidget {
  const SignupScreenDemo({super.key});

  @override
  State<SignupScreenDemo> createState() => _SignupScreenDemoState();
}

class _SignupScreenDemoState extends State<SignupScreenDemo>
    with TickerProviderStateMixin {
  // --- Controllers ---
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // --- Focus Nodes for keyboard dismissal ---
  final _firstNameFocus = FocusNode();
  final _lastNameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _mobileFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmPasswordFocus = FocusNode();

  // --- State ---
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  int _currentStep = 0;

  // Animation declarations
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    // Dispose controllers
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    // Dispose focus nodes
    _firstNameFocus.dispose();
    _lastNameFocus.dispose();
    _emailFocus.dispose();
    _mobileFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();

    // Dispose animations
    _animationController.dispose();

    super.dispose();
  }

  // --- Dismiss Keyboard when tapping outside ---
  void _dismissKeyboard() {
    FocusScope.of(context).unfocus();
  }

  // --- Validation ---
  bool _validateInputs() {
    final fName = _firstNameController.text.trim();
    final lName = _lastNameController.text.trim();
    final email = _emailController.text.trim();
    final mobile = _mobileController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (fName.isEmpty ||
        lName.isEmpty ||
        email.isEmpty ||
        mobile.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      _showSnackBar('Please fill in all fields', isError: true);
      return false;
    }

    if (!_isValidEmail(email)) {
      _showSnackBar('Please enter a valid email address', isError: true);
      return false;
    }

    if (mobile.length < 10) {
      _showSnackBar('Please enter a valid mobile number', isError: true);
      return false;
    }

    if (password.length < 8) {
      _showSnackBar('Password must be at least 8 characters', isError: true);
      return false;
    }

    if (!_hasUpperCase(password)) {
      _showSnackBar(
        'Password must contain at least one uppercase letter',
        isError: true,
      );
      return false;
    }

    if (!_hasNumber(password)) {
      _showSnackBar('Password must contain at least one number', isError: true);
      return false;
    }

    if (password != confirmPassword) {
      _showSnackBar('Passwords do not match', isError: true);
      return false;
    }

    return true;
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool _hasUpperCase(String password) {
    return password.contains(RegExp(r'[A-Z]'));
  }

  bool _hasNumber(String password) {
    return password.contains(RegExp(r'[0-9]'));
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_rounded : Icons.check_circle_rounded,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? AppColors.emergencyRed : AppColors.safeGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // --- Navigation ---
  void _nextStep() {
    _dismissKeyboard(); // Dismiss keyboard when moving to next step

    // Validate current step before proceeding
    if (_currentStep == 0) {
      if (_firstNameController.text.trim().isEmpty ||
          _lastNameController.text.trim().isEmpty) {
        _showSnackBar('Please fill in all fields', isError: true);
        return;
      }
    } else if (_currentStep == 1) {
      if (_emailController.text.trim().isEmpty ||
          _mobileController.text.trim().isEmpty) {
        _showSnackBar('Please fill in all fields', isError: true);
        return;
      }

      if (!_isValidEmail(_emailController.text.trim())) {
        _showSnackBar('Please enter a valid email address', isError: true);
        return;
      }

      if (_mobileController.text.trim().length < 10) {
        _showSnackBar('Please enter a valid mobile number', isError: true);
        return;
      }
    }

    if (_currentStep < 2) {
      setState(() => _currentStep++);
    }
  }

  void _previousStep() {
    _dismissKeyboard(); // Dismiss keyboard when moving to previous step
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  // --- Logic ---
  Future<void> _handleSignup() async {
    _dismissKeyboard(); // Dismiss keyboard when submitting

    if (!_validateInputs()) return;

    final input = SignupInput(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      email: _emailController.text.trim(),
      mobile: _mobileController.text.trim(),
      password: _passwordController.text,
      middleName: "",
    );

    setState(() => _isLoading = true);

    try {
      final authService = context.read<AuthService>();
      await authService.signup(input);

      if (!mounted) return;

      _showDialog(
        title: "Account Created! 🎉",
        message:
            "Your account has been created successfully. Please login to continue.",
        icon: Icons.check_circle_rounded,
        iconColor: AppColors.safeGreen,
        buttonText: "Go to Login",
        onPressed: () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          );
        },
      );
    } catch (e) {
      debugPrint('Signup Error: $e');
      if (!mounted) return;

      _showDialog(
        title: "Signup Failed",
        message: e.toString().replaceAll('Exception: ', ''),
        icon: Icons.error_rounded,
        iconColor: AppColors.emergencyRed,
        buttonText: "Try Again",
        onPressed: () => Navigator.pop(context),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showDialog({
    required String title,
    required String message,
    required IconData icon,
    required Color iconColor,
    required String buttonText,
    required VoidCallback onPressed,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: iconColor.withOpacity(0.1),
                ),
                child: Icon(icon, size: 48, color: iconColor),
              ),
              const SizedBox(height: 24),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, height: 1.5),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: iconColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(buttonText),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Step Builders ---
  Widget _buildStepIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return GestureDetector(
          onTap: () {
            if (index <= _currentStep) {
              setState(() => _currentStep = index);
            }
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: _currentStep == index ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: _currentStep >= index
                  ? AppColors.safeGreen
                  : Colors.grey.withOpacity(0.3),
            ),
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
          focusNode: _firstNameFocus,
          label: "First Name",
          icon: Icons.person_outline_rounded,
          inputType: TextInputType.name,
          onSubmitted: (_) => _firstNameFocus.nextFocus(),
        ),
        const SizedBox(height: 20),
        CustomTextField(
          controller: _lastNameController,
          focusNode: _lastNameFocus,
          label: "Last Name",
          icon: Icons.person_outline_rounded,
          inputType: TextInputType.name,
          onSubmitted: (_) => _nextStep(),
        ),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      children: [
        CustomTextField(
          controller: _emailController,
          focusNode: _emailFocus,
          label: "Email Address",
          icon: Icons.email_outlined,
          inputType: TextInputType.emailAddress,
          onSubmitted: (_) => _emailFocus.nextFocus(),
        ),
        const SizedBox(height: 20),
        CustomTextField(
          controller: _mobileController,
          focusNode: _mobileFocus,
          label: "Mobile Number",
          icon: Icons.phone_android_rounded,
          inputType: TextInputType.phone,
          onSubmitted: (_) => _nextStep(),
        ),
      ],
    );
  }

  Widget _buildStep3() {
    return Column(
      children: [
        CustomTextField(
          controller: _passwordController,
          focusNode: _passwordFocus,
          label: "Password",
          icon: Icons.lock_outline_rounded,
          isPassword: true,
          onSubmitted: (_) => _passwordFocus.nextFocus(),
        ),
        const SizedBox(height: 20),
        CustomTextField(
          controller: _confirmPasswordController,
          focusNode: _confirmPasswordFocus,
          label: "Confirm Password",
          icon: Icons.lock_outline_rounded,
          isPassword: true,
          onSubmitted: (_) => _handleSignup(),
        ),
        const SizedBox(height: 16),
        // Password requirements
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest.withOpacity(0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
              width: 1,
            ),
          ),
          child: Column(
            children: [
              _buildRequirement(
                "At least 8 characters",
                _passwordController.text.length >= 8,
              ),
              const SizedBox(height: 8),
              _buildRequirement(
                "Contains uppercase letter",
                _hasUpperCase(_passwordController.text),
              ),
              const SizedBox(height: 8),
              _buildRequirement(
                "Contains number",
                _hasNumber(_passwordController.text),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRequirement(String text, bool isMet) {
    return Row(
      children: [
        Icon(
          isMet
              ? Icons.check_circle_rounded
              : Icons.radio_button_unchecked_rounded,
          color: isMet ? AppColors.safeGreen : Colors.grey,
          size: 20,
        ),
        const SizedBox(width: 12),
        Text(
          text,
          style: TextStyle(
            color: isMet ? AppColors.safeGreen : Colors.grey,
            fontSize: 14,
            decoration: isMet ? TextDecoration.lineThrough : null,
            decorationColor: AppColors.safeGreen.withOpacity(0.5),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isSmallScreen = screenWidth < 400;

    return GestureDetector(
      // TAP OUTSIDE TO DISMISS KEYBOARD
      onTap: _dismissKeyboard,
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: Text(
            "Register",
            style: TextStyle(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
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
          centerTitle: true,
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                theme.scaffoldBackgroundColor,
                colorScheme.surfaceContainerHighest.withOpacity(0.3),
              ],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 16 : 24,
                  vertical: 20,
                ),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // --- Logo with Gradient Background ---
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                AppColors.safeGreen.withOpacity(0.2),
                                AppColors.navBlue.withOpacity(0.2),
                              ],
                            ),
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

                        // --- Header ---
                        AuthHeader(
                          title: "Join Synquerra",
                          subtitle: "Create an account to start tracking",
                        ),
                        const SizedBox(height: 32),

                        // --- Step Indicator ---
                        _buildStepIndicator(),
                        const SizedBox(height: 32),

                        // --- Form Fields with Animation ---
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          transitionBuilder:
                              (Widget child, Animation<double> animation) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: SlideTransition(
                                    position: Tween<Offset>(
                                      begin: const Offset(0.1, 0),
                                      end: Offset.zero,
                                    ).animate(animation),
                                    child: child,
                                  ),
                                );
                              },
                          child: Container(
                            key: ValueKey(_currentStep),
                            width: screenWidth * 0.9,
                            child: Column(
                              children: [
                                if (_currentStep == 0) _buildStep1(),
                                if (_currentStep == 1) _buildStep2(),
                                if (_currentStep == 2) _buildStep3(),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // --- Navigation Buttons ---
                        Row(
                          children: [
                            if (_currentStep > 0)
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: _previousStep,
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    side: BorderSide(
                                      color: colorScheme.outlineVariant,
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
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 16,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                      ),
                                      child: const Text("Next"),
                                    )
                                  : LoadingButton(
                                      onPressed: _handleSignup,
                                      isLoading: _isLoading,
                                      label: "Create Account",
                                      backgroundColor: AppColors.safeGreen,
                                      icon: Icons.check_rounded,
                                    ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // --- Login Link ---
                        AuthFooter(
                          question: "Already have an account?",
                          actionLabel: "Sign In",
                          onActionTap: () {
                            _dismissKeyboard();
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const LoginScreen(),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 16),

                        // --- Terms and Conditions ---
                        Text(
                          "By signing up, you agree to our Terms of Service and Privacy Policy",
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant.withOpacity(
                              0.7,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
