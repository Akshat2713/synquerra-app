import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:synquerra/core/models/signup_input.dart';
import 'package:synquerra/core/services/auth_service.dart';
import 'package:synquerra/screens/registration/login_page.dart';
// import 'package:synquerra/screens/login_screen.dart'; // To navigate after success
import 'package:synquerra/theme/colors.dart'; // Ensure this path is correct

class SignupScreenDemo extends StatefulWidget {
  const SignupScreenDemo({super.key});

  @override
  State<SignupScreenDemo> createState() => _SignupScreenDemoState();
}

class _SignupScreenDemoState extends State<SignupScreenDemo> {
  // --- Controllers ---
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();

  // --- State ---
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --- Logic ---
  Future<void> _handleSignup() async {
    final fName = _firstNameController.text.trim();
    final lName = _lastNameController.text.trim();
    final email = _emailController.text.trim();
    final mobile = _mobileController.text.trim();
    final password = _passwordController.text;

    // 1. Validation
    if (fName.isEmpty ||
        lName.isEmpty ||
        email.isEmpty ||
        mobile.isEmpty ||
        password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // 2. Prepare Data
    final input = SignupInput(
      firstName: fName,
      lastName: lName,
      email: email,
      mobile: mobile,
      password: password,
      middleName: "", // API allows this to be empty
    );

    setState(() => _isLoading = true);

    // Dismiss keyboard
    FocusScope.of(context).unfocus();

    try {
      // 3. Call API
      // await AuthService(null).signup(input);
      final authService = context.read<AuthService>();
      await authService.signup(input);

      if (!mounted) return;

      // 4. Success
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account created successfully! Please Login.'),
          backgroundColor: AppColors.safeGreen,
        ),
      );

      // 5. Navigate to Login (Clear stack so they can't go back)
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      debugPrint('Signup Error: $e');
      // 6. Error
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Signup Failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Create Account"),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 20.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // --- Header ---
                Text(
                  "Join Synquerra",
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Create an account to start tracking",
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 40),

                // --- Form Fields ---
                SizedBox(
                  width: screenWidth * 0.9, // Constrain width slightly
                  child: Column(
                    children: [
                      _buildTextField(
                        controller: _firstNameController,
                        labelText: "First Name",
                        icon: Icons.person,
                        context: context,
                      ),
                      const SizedBox(height: 20),

                      _buildTextField(
                        controller: _lastNameController,
                        labelText: "Last Name",
                        icon: Icons.person_outline,
                        context: context,
                      ),
                      const SizedBox(height: 20),

                      _buildTextField(
                        controller: _emailController,
                        labelText: "Email Address",
                        icon: Icons.email_outlined,
                        inputType: TextInputType.emailAddress,
                        context: context,
                      ),
                      const SizedBox(height: 20),

                      _buildTextField(
                        controller: _mobileController,
                        labelText: "Mobile Number",
                        icon: Icons.phone_android,
                        inputType: TextInputType.phone,
                        context: context,
                      ),
                      const SizedBox(height: 20),

                      _buildTextField(
                        controller: _passwordController,
                        labelText: "Password",
                        icon: Icons.lock_outline,
                        isPassword: true,
                        context: context,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // --- Sign Up Button ---
                SizedBox(
                  width: screenWidth * 0.9,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isLoading
                          ? Colors.grey
                          : AppColors.safeGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 2,
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _isLoading ? null : _handleSignup,
                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text("Sign Up"),
                  ),
                ),

                const SizedBox(height: 30),

                // --- Login Link ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account? ",
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                        );
                      },
                      child: Text(
                        "Login",
                        style: TextStyle(
                          color: AppColors.navBlue, // Or your primary color
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.navBlue,
                        ),
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
  }

  // --- Reused UI Helper to match your exact style ---
  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    required BuildContext context,
    TextInputType inputType = TextInputType.text,
    bool isPassword = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return TextField(
      controller: controller,
      keyboardType: inputType,
      obscureText: isPassword && !_isPasswordVisible,
      style: TextStyle(color: colorScheme.onSurface),
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon, color: colorScheme.onSurfaceVariant),
        // Add Password Toggle Icon
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: colorScheme.onSurfaceVariant,
                ),
                onPressed: () =>
                    setState(() => _isPasswordVisible = !_isPasswordVisible),
              )
            : null,
        labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        filled: true,
        // Using your specific opacity style
        fillColor: colorScheme.surfaceVariant.withOpacity(0.5),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outlineVariant, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.safeGreen, width: 2),
        ),
      ),
    );
  }
}
