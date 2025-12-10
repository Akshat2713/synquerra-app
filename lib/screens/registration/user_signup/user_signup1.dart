import 'package:flutter/material.dart';
import 'package:safe_track/screens/registration/user_signup/user_signup2.dart';
import 'package:safe_track/theme/colors.dart'; // Assuming AppColors.safeGreen is here

class RegistrationStep1 extends StatefulWidget {
  const RegistrationStep1({super.key});

  @override
  State<RegistrationStep1> createState() => _RegistrationStep1State();
}

class _RegistrationStep1State extends State<RegistrationStep1> {
  final _deviceIdController = TextEditingController();
  final _deviceNameController = TextEditingController();
  final _activationCodeController = TextEditingController();

  @override
  void dispose() {
    _deviceIdController.dispose();
    _deviceNameController.dispose();
    _activationCodeController.dispose();
    super.dispose();
  }

  void _submitAndNext() {
    final deviceId = _deviceIdController.text;
    final deviceName = _deviceNameController.text;
    final activationCode = _activationCodeController.text;

    // --- Validation ---
    if (deviceId.isEmpty || deviceName.isEmpty || activationCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields.')),
      );
      return;
    }

    // Navigate to the next step
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RegistrationStep2()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    // Get screen width for constraining elements
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor, // Theme-based background
      appBar: AppBar(
        title: const Text("Register Device"),
        backgroundColor: theme.appBarTheme.backgroundColor,
      ),
      // --- CHANGED: Removed SingleChildScrollView ---
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        child: Column(
          // --- CHANGED: Centered all children horizontally ---
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // --- Step Indicator (Stays at top) ---
            _buildStepIndicator(context, currentStep: 1),
            const SizedBox(height: 30),

            // --- CHANGED: Wrapped form content in Expanded to center vertically ---
            Expanded(
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center, // Center vertically
                crossAxisAlignment:
                    CrossAxisAlignment.center, // Center horizontally
                children: [
                  // --- Title ---
                  Text(
                    "Device Details",
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                      decorationColor: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // --- Text Fields ---
                  SizedBox(
                    width: screenWidth * 0.85, // Constrain width
                    child: _buildTextField(
                      controller: _deviceIdController,
                      labelText: "Device ID",
                      context: context,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: screenWidth * 0.85, // Constrain width
                    child: _buildTextField(
                      controller: _deviceNameController,
                      labelText: "Device name/ Label",
                      context: context,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: screenWidth * 0.85, // Constrain width
                    child: _buildTextField(
                      controller: _activationCodeController,
                      labelText: "Activation Code",
                      context: context,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // --- Submit Button ---
                  SizedBox(
                    width: screenWidth * 0.85, // Constrain width
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            AppColors.safeGreen, // Green background
                        foregroundColor: Colors.white, // White text
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            12,
                          ), // Less rounded
                        ),
                      ),
                      onPressed: _submitAndNext,
                      child: const Text("Submit and Next"),
                    ),
                  ),
                ],
              ),
            ),
            // Add some space at the bottom if needed, or remove for true centering
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Helper widget for the step indicator
  Widget _buildStepIndicator(BuildContext context, {required int currentStep}) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Widget buildStep(int step) {
      final bool isActive = step == currentStep;
      final bool isCompleted = step < currentStep;

      Color boxColor = isActive
          ? AppColors
                .safeGreen // Active step color
          : (isCompleted ? colorScheme.primary : colorScheme.surfaceVariant);
      Color textColor = isActive
          ? Colors.white
          : (isCompleted
                ? colorScheme.onPrimary
                : colorScheme.onSurfaceVariant);

      return Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: boxColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive
                ? AppColors.safeGreen
                : (isCompleted
                      ? colorScheme.primary
                      : colorScheme.outlineVariant),
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            "$step",
            style: theme.textTheme.titleLarge?.copyWith(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    Widget buildLine() {
      // --- Kept fixed-width Container for closer spacing ---
      return Container(
        width: 40, // Shorter line width
        height: 2,
        color: colorScheme.outlineVariant,
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        buildStep(1),
        buildLine(),
        buildStep(2),
        buildLine(),
        buildStep(3),
      ],
    );
  }

  // Helper widget for a styled text field
  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required BuildContext context,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return TextField(
      controller: controller,
      style: TextStyle(color: colorScheme.onSurface),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        filled: true,
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
          borderSide: BorderSide(
            color: AppColors.safeGreen,
            width: 2,
          ), // Focus color
        ),
      ),
    );
  }
}
