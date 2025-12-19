import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:synquerra/screens/landing/map_screen.dart';
import 'package:synquerra/theme/colors.dart'; // Assuming AppColors.safeGreen is here

class RegistrationStep4 extends StatefulWidget {
  const RegistrationStep4({super.key});

  @override
  State<RegistrationStep4> createState() => _RegistrationStep4State();
}

class _RegistrationStep4State extends State<RegistrationStep4> {
  // State variables for the checkboxes
  bool _confirmOwnDevice = false;
  bool _confirmMinor = false;
  bool _agreeTerms = false;

  void _submit() {
    // Validation: Check if all boxes are checked
    if (!_confirmOwnDevice || !_confirmMinor || !_agreeTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must agree to all terms to continue.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // --- TODO: Implement final registration logic here ---
    print('All agreements confirmed. Submitting registration...');

    // Navigate to a final screen, e.g., the main map screen
    // We use pushAndRemoveUntil to clear the registration stack
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const MapScreen()),
      (Route<dynamic> route) => false, // This predicate removes all routes
    );
  }

  void _openTerms() {
    // --- TODO: Implement navigation to your Terms & Privacy screen or URL ---
    print('Navigate to Terms & Privacy');
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Opening Terms & Privacy...')));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final double screenWidth = MediaQuery.of(context).size.width;

    // Check if all are checked to enable the button
    final bool allChecked = _confirmOwnDevice && _confirmMinor && _agreeTerms;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Agreements"),
        backgroundColor: theme.appBarTheme.backgroundColor,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Center vertically
            crossAxisAlignment:
                CrossAxisAlignment.center, // Center horizontally
            children: [
              // --- Title ---
              Text(
                "Agreements",
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),

              // --- Checkbox List ---
              SizedBox(
                width: screenWidth * 0.85,
                child: Column(
                  children: [
                    // --- Checkbox 1 ---
                    CheckboxListTile(
                      title: Text(
                        "I confirm I am registering my own device",
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurface,
                        ),
                      ),
                      value: _confirmOwnDevice,
                      onChanged: (bool? value) {
                        setState(() => _confirmOwnDevice = value!);
                      },
                      activeColor: AppColors.safeGreen,
                      controlAffinity:
                          ListTileControlAffinity.leading, // Box on left
                      contentPadding: EdgeInsets.zero,
                    ),
                    const SizedBox(height: 15),

                    // --- Checkbox 2 ---
                    CheckboxListTile(
                      title: Text(
                        "I confirm I am authorized to register this device on behalf of a minor.",
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurface,
                        ),
                      ),
                      value: _confirmMinor,
                      onChanged: (bool? value) {
                        setState(() => _confirmMinor = value!);
                      },
                      activeColor: AppColors.safeGreen,
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                    ),
                    const SizedBox(height: 15),

                    // --- Checkbox 3 with Link ---
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Checkbox(
                          value: _agreeTerms,
                          onChanged: (bool? value) {
                            setState(() => _agreeTerms = value!);
                          },
                          activeColor: AppColors.safeGreen,
                          checkColor:
                              colorScheme.onPrimary, // Color of the checkmark
                        ),
                        Expanded(
                          // Use RichText to make part of the text tappable
                          child: RichText(
                            text: TextSpan(
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: colorScheme.onSurface,
                              ),
                              children: [
                                const TextSpan(text: "I agree to "),
                                TextSpan(
                                  text: "Terms & Privacy Policy",
                                  style: TextStyle(
                                    color: colorScheme.primary, // Link color
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline,
                                    decorationColor: colorScheme.primary,
                                  ),
                                  // Add gesture recognizer to make it tappable
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = _openTerms,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 50),

              // --- Submit Button ---
              SizedBox(
                width: screenWidth * 0.85,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: allChecked
                        ? AppColors.safeGreen
                        : Colors.grey[600], // Change color if disabled
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  // Disable button if not all are checked
                  onPressed: allChecked ? _submit : null,
                  child: const Text("Submit"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
