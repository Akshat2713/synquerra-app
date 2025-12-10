import 'package:flutter/material.dart';
import 'package:safe_track/screens/registration/user_signup/user_signup1.dart';
import 'package:safe_track/screens/registration/user_signup/user_signup_demo.dart';
import 'package:safe_track/theme/colors.dart'; // Assuming your AppColors.navBlue is here
// Import a dummy screen or your next registration step screen
import 'package:safe_track/widgets/dummy_screen.dart';

// Enum to manage which role is selected
enum RegistrationType { none, organization, user }

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // State variable to track the selected registration type
  RegistrationType _selectedType = RegistrationType.none;

  void _proceedToNext() {
    if (_selectedType == RegistrationType.none) {
      // Show error if nothing is selected (though button should be disabled)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a registration type.')),
      );
      return;
    }

    // Navigate to the next step based on selection

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _selectedType == RegistrationType.organization
            ? DummyScreen(title: "Organization Registration")
            : SignupScreenDemo(),
      ),
    );
  }

  void _signIn() {
    // Navigate back to the Login Screen
    // If you pushed this screen from Login, pop is correct.
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      // Fallback if this is the first screen (e.g., during development)
      // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme; // Use theme color scheme

    // Colors are now derived from the theme
    final Color textColor = colorScheme.onSurface;
    final Color hintColor = colorScheme.onSurfaceVariant;
    final Color linkColor = AppColors.navBlue;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor, // Use theme background
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),

                // --- App Logo ---
                Image.asset('assets/images/app_logo.png', height: 250),
                const SizedBox(height: 20),

                // --- Title ---
                Text(
                  "Sign Up to Synquerra",
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineLarge?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40),

                // --- Register as an Organization ---
                _buildSelectionCard(
                  context: context,
                  icon: Icons.groups_rounded,
                  text: "Register as an Organization",
                  type: RegistrationType.organization,
                  isSelected: _selectedType == RegistrationType.organization,
                ),
                const SizedBox(height: 20),

                // --- Register as a User ---
                _buildSelectionCard(
                  context: context,
                  icon: Icons.person_rounded,
                  text: "Register as an User",
                  type: RegistrationType.user,
                  isSelected: _selectedType == RegistrationType.user,
                ),
                const SizedBox(height: 40),

                // --- Next Button ---
                _buildNextButton(context), // Pass context for theme
                const SizedBox(height: 30),

                // --- Sign In Link ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Have an account? ",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: hintColor,
                        fontSize: 18,
                      ),
                    ),
                    TextButton(
                      onPressed: _signIn,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        "Sign In",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: linkColor,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                          decorationColor: linkColor,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper widget for the selectable cards
  Widget _buildSelectionCard({
    required BuildContext context,
    required IconData icon,
    required String text,
    required RegistrationType type,
    required bool isSelected,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Define selected and unselected styles using theme colors
    final Color cardColor = isSelected
        ? AppColors
              .safeGreen // Highlighted color
        : colorScheme.surfaceVariant; // Default container color from theme
    final Color contentColor = isSelected
        ? colorScheme
              .onPrimary // Text/icon color on primary
        : colorScheme.onSurfaceVariant; // Text/icon color on surface variant
    final Border border = isSelected
        ? Border.all(
            color: colorScheme.outlineVariant,
            width: 2.0,
          ) // Highlight border
        : Border.all(color: Colors.transparent, width: 2.0); // No border

    return GestureDetector(
      onTap: () {
        // Update the state when tapped
        setState(() {
          _selectedType = type;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(15),
          border: border,
          boxShadow: [
            if (isSelected) // Add a "glow" shadow when selected
              BoxShadow(
                color: colorScheme.primary.withOpacity(0.2),
                blurRadius: 10,
                spreadRadius: 2,
              ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 50, color: contentColor),
            const SizedBox(height: 16),
            Text(
              text,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                color: contentColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper for the gradient "Next" button
  Widget _buildNextButton(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Button is disabled if no type is selected
    bool isEnabled = _selectedType != RegistrationType.none;

    // Define gradients based on theme
    final activeGradient = LinearGradient(
      colors: [colorScheme.primary, colorScheme.secondary], // Use theme colors
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );
    final disabledGradient = LinearGradient(
      colors: [
        colorScheme.onSurface.withOpacity(0.1),
        colorScheme.onSurface.withOpacity(0.05),
      ], // Use theme-aware disabled colors
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );

    return Container(
      decoration: BoxDecoration(
        gradient: isEnabled
            ? activeGradient
            : disabledGradient, // Apply correct gradient
        borderRadius: BorderRadius.circular(30),
        boxShadow: isEnabled
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: ElevatedButton(
        onPressed: isEnabled ? _proceedToNext : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          disabledForegroundColor: colorScheme.onSurface.withOpacity(0.4),
        ),
        child: Text(
          "Next",
          style: TextStyle(
            color: isEnabled
                ? colorScheme
                      .onPrimary // Text color for active button
                : colorScheme.onSurface.withOpacity(
                    0.4,
                  ), // Text color for disabled
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
