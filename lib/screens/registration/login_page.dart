import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:synquerra/providers/user_provider.dart';
import 'package:synquerra/screens/landing/map_screen.dart';
import 'package:synquerra/screens/registration/signup_screen1.dart';
import 'package:synquerra/theme/colors.dart';
import '../../core/models/user_model.dart';
import '../../core/services/auth_service.dart';
import '../../core/preferences/user_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  // final AuthService _authService = AuthService(null);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    // --- TODO: Implement your sign-in logic here ---
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both email and password.')),
      );
      return; // Stop execution if fields are empty
    }

    FocusScope.of(context).unfocus();

    setState(() => _isLoading = true);

    try {
      final authService = context.read<AuthService>();
      final AuthResponse authResponse = await authService.login(
        email,
        password,
      );

      if (authResponse.data != null) {
        await UserPreferences().saveUser(authResponse.data!);

        if (mounted) {
          context.read<UserProvider>().setUser(authResponse.data!);
        }

        debugPrint(
          "--- [LOGIN] Session updated. ProxyProvider will now trigger auto-fetch. ---",
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Welcome Back, ${authResponse.data?.firstName}!'),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MapScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false; // Stop spinner
        });
      }
    }
  }

  void _signUp() {
    // --- Implement navigation to your Sign Up screen ---
    print('Navigate to Sign Up');
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SignUpScreen()), // Use const
    ); // Example navigation
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme; // Use theme color scheme

    // Colors are now derived from the theme
    final Color textColor = colorScheme.onSurface; // Color for text on surface
    final Color hintColor = colorScheme.onSurfaceVariant; // Color for hints
    final Color fieldBackgroundColor =
        colorScheme.surfaceContainerHighest; // Color for text field background
    final Color linkColor = AppColors.navBlue; // Color for links

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor, // Use theme background
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              // Main column for logo + container
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // --- App Logo (Moved Outside Container) ---
                Image.asset(
                  'assets/images/app_logo.png',
                  height: 250, // Adjusted size
                  // Add a fallback in case the image fails to load
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.school_outlined, // Fallback icon
                      size: 100,
                      color: colorScheme.primary,
                    );
                  },
                ),
                const SizedBox(height: 30), // Spacing between logo and card
                // --- Content Container ---
                Container(
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color:
                        colorScheme.surface, // Use surface color for the card
                    borderRadius: BorderRadius.circular(20), // Rounded corners
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // --- Title ---
                      Text(
                        "Sign in to Synquerra", // Using name from image
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineLarge?.copyWith(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 40),

                      // --- Email Field ---
                      Text(
                        "Email",
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: hintColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        enabled: !_isLoading,
                        style: TextStyle(
                          color:
                              colorScheme.onSurface, // Text color inside field
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: _buildInputDecoration(
                          hintText: 'Email',
                          fillColor: fieldBackgroundColor,
                          hintColor: hintColor, // Pass hint color
                          context: context,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // --- Password Field ---
                      Text(
                        "Password",
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: hintColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        enabled: !_isLoading,
                        style: TextStyle(
                          color:
                              colorScheme.onSurface, // Text color inside field
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: _buildInputDecoration(
                          hintText: 'Password',
                          fillColor: fieldBackgroundColor,
                          hintColor: hintColor, // Pass hint color
                          context: context,
                        ),
                      ),
                      const SizedBox(height: 30),

                      // --- Sign In Button ---
                      _buildSignInButton(context), // Pass context for theme
                      const SizedBox(height: 30),

                      // --- Sign Up Link ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account? ",
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: hintColor,
                            ),
                          ),
                          TextButton(
                            onPressed: _isLoading ? null : _signUp,
                            style: TextButton.styleFrom(
                              padding:
                                  EdgeInsets.zero, // Remove default padding
                              tapTargetSize: MaterialTapTargetSize
                                  .shrinkWrap, // Fit content
                            ),

                            child: Text(
                              "Sign Up",
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: linkColor,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                                decorationColor: linkColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20), // Padding at the bottom
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper for text field decoration
  InputDecoration _buildInputDecoration({
    required String hintText,
    required Color fillColor,
    required Color hintColor,
    required BuildContext context,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(
        color: hintColor.withOpacity(0.7), // Use theme hint color
        fontWeight: FontWeight.w400,
      ),
      filled: true,
      fillColor: fillColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),

      // Default border (when not focused)
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        // Use a subtle border color
        borderSide: BorderSide(color: hintColor.withOpacity(0.3), width: 1.5),
      ),

      // Border when enabled (but not focused)
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        // Use a subtle border color
        borderSide: BorderSide(color: hintColor.withOpacity(0.3), width: 1.5),
      ),

      // Border when focused (selected)
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: AppColors.safeGreen, // Highlight with safeGreen
          width: 2,
        ),
      ),
    );
  }

  // Helper for the gradient sign-in button
  Widget _buildSignInButton(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Define gradients based on theme
    final activeGradient = LinearGradient(
      colors: [colorScheme.primary, colorScheme.secondary], // Use theme colors
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );

    return Container(
      decoration: BoxDecoration(
        gradient: _isLoading ? null : activeGradient, // Apply correct gradient
        borderRadius: BorderRadius.circular(30), // Match button shape
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _signIn,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent, // Make button transparent
          shadowColor: Colors.transparent, // Hide default shadow
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: _isLoading
            // Show Spinner if loading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                "Sign In",
                style: TextStyle(
                  color: colorScheme.onPrimary, // Text color for active button
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
