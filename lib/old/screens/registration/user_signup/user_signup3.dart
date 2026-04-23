import 'package:flutter/material.dart';
import 'package:synquerra/old/screens/registration/user_signup/user_signup4.dart';
import 'package:synquerra/old/theme/colors.dart'; // Assuming AppColors.safeGreen is here

class RegistrationStep3 extends StatefulWidget {
  const RegistrationStep3({super.key});

  @override
  State<RegistrationStep3> createState() => _RegistrationStep3State();
}

class _RegistrationStep3State extends State<RegistrationStep3> {
  // --- State for Guardian 1 ---
  final _g1UserIdController = TextEditingController();
  final _g1FirstNameController = TextEditingController();
  final _g1LastNameController = TextEditingController();
  final _g1AadharController = TextEditingController();
  final _g1PhoneController = TextEditingController();
  final _g1EmailController = TextEditingController();
  final _g1PinController = TextEditingController();
  final _g1Address1Controller = TextEditingController();
  final _g1Address2Controller = TextEditingController();
  final _g1Address3Controller = TextEditingController();
  String? _g1SelectedRelationship;
  String? _g1SelectedState;
  String? _g1SelectedCity;

  // --- State for Guardian 2 ---
  final _g2UserIdController = TextEditingController();
  final _g2FirstNameController = TextEditingController();
  final _g2LastNameController = TextEditingController();
  final _g2AadharController = TextEditingController();
  final _g2PhoneController = TextEditingController();
  final _g2EmailController = TextEditingController();
  final _g2PinController = TextEditingController();
  final _g2Address1Controller = TextEditingController();
  final _g2Address2Controller = TextEditingController();
  final _g2Address3Controller = TextEditingController();
  String? _g2SelectedRelationship;
  String? _g2SelectedState;
  String? _g2SelectedCity;

  // --- UI State ---
  bool _showGuardian2 = false;

  // --- Dummy Data ---
  final List<String> _relationships = ['Father', 'Mother', 'Guardian', 'Other'];
  final List<String> _states = ['State 1', 'State 2', 'State 3'];
  final List<String> _cities = ['City 1', 'City 2', 'City 3'];

  @override
  void dispose() {
    // Dispose G1 controllers
    _g1UserIdController.dispose();
    _g1FirstNameController.dispose();
    _g1LastNameController.dispose();
    _g1AadharController.dispose();
    _g1PhoneController.dispose();
    _g1EmailController.dispose();
    _g1PinController.dispose();
    _g1Address1Controller.dispose();
    _g1Address2Controller.dispose();
    _g1Address3Controller.dispose();

    // Dispose G2 controllers
    _g2UserIdController.dispose();
    _g2FirstNameController.dispose();
    _g2LastNameController.dispose();
    _g2AadharController.dispose();
    _g2PhoneController.dispose();
    _g2EmailController.dispose();
    _g2PinController.dispose();
    _g2Address1Controller.dispose();
    _g2Address2Controller.dispose();
    _g2Address3Controller.dispose();
    super.dispose();
  }

  // --- NEW: Helper to clear Guardian 2 fields ---
  void _clearGuardian2Fields() {
    _g2UserIdController.clear();
    _g2FirstNameController.clear();
    _g2LastNameController.clear();
    _g2AadharController.clear();
    _g2PhoneController.clear();
    _g2EmailController.clear();
    _g2PinController.clear();
    _g2Address1Controller.clear();
    _g2Address2Controller.clear();
    _g2Address3Controller.clear();
    _g2SelectedRelationship = null;
    _g2SelectedState = null;
    _g2SelectedCity = null;
  }

  void _submitAndNext() {
    // --- Guardian 1 Validation ---
    if (_g1FirstNameController.text.isEmpty ||
        _g1LastNameController.text.isEmpty ||
        _g1SelectedRelationship == null ||
        _g1AadharController.text.isEmpty ||
        _g1PhoneController.text.isEmpty ||
        _g1EmailController.text.isEmpty ||
        _g1PinController.text.isEmpty ||
        _g1SelectedState == null ||
        _g1SelectedCity == null ||
        _g1Address1Controller.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields for Guardian 1.'),
        ),
      );
      return;
    }

    // --- Guardian 2 Validation (if visible) ---
    if (_showGuardian2) {
      if (_g2FirstNameController.text.isEmpty ||
          _g2LastNameController.text.isEmpty ||
          _g2SelectedRelationship == null ||
          _g2AadharController.text.isEmpty ||
          _g2PhoneController.text.isEmpty ||
          _g2EmailController.text.isEmpty ||
          _g2PinController.text.isEmpty ||
          _g2SelectedState == null ||
          _g2SelectedCity == null ||
          _g2Address1Controller.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please fill in all fields for Guardian 2.'),
          ),
        );
        return;
      }
    }

    // --- TODO: Implement submission logic ---
    print('Guardian 1 Data:');
    print('Name: ${_g1FirstNameController.text} ${_g1LastNameController.text}');
    // ... print other G1 data

    if (_showGuardian2) {
      print('---');
      print('Guardian 2 Data:');
      print(
        'Name: ${_g2FirstNameController.text} ${_g2LastNameController.text}',
      );
      // ... print other G2 data
    }

    // Navigate to next step
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RegistrationStep4()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Guardian Details"),
        backgroundColor: theme.appBarTheme.backgroundColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // --- Step Indicator ---
            _buildStepIndicator(context, currentStep: 3),
            const SizedBox(height: 30),

            // --- Title ---
            Text(
              "Guardian Details",
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
                decorationColor: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),

            // --- Guardian 1 Form ---
            _buildGuardianForm(
              context: context,
              guardianNumber: 1,
              userIdController: _g1UserIdController,
              firstNameController: _g1FirstNameController,
              lastNameController: _g1LastNameController,
              aadharController: _g1AadharController,
              phoneController: _g1PhoneController,
              emailController: _g1EmailController,
              pinController: _g1PinController,
              address1Controller: _g1Address1Controller,
              address2Controller: _g1Address2Controller,
              address3Controller: _g1Address3Controller,
              selectedRelationship: _g1SelectedRelationship,
              selectedState: _g1SelectedState,
              selectedCity: _g1SelectedCity,
              onRelationshipChanged: (val) =>
                  setState(() => _g1SelectedRelationship = val),
              onStateChanged: (val) => setState(() => _g1SelectedState = val),
              onCityChanged: (val) => setState(() => _g1SelectedCity = val),
              // No onRemove callback for Guardian 1
            ),

            // --- "Add Guardian 2" Button & Form ---
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // If G2 is hidden, show the "Add" button
                  if (!_showGuardian2)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      child: TextButton.icon(
                        icon: Icon(Icons.add, color: Colors.black),
                        label: Text(
                          "Add Guardian 2 (optional)",
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            _showGuardian2 = true;
                          });
                        },
                      ),
                    )
                  else // If G2 is visible, show the form
                    Column(
                      children: [
                        const SizedBox(height: 20),
                        Divider(
                          color: colorScheme.outlineVariant,
                          thickness: 1,
                        ),
                        const SizedBox(height: 20),
                        _buildGuardianForm(
                          context: context,
                          guardianNumber: 2,
                          userIdController: _g2UserIdController,
                          firstNameController: _g2FirstNameController,
                          lastNameController: _g2LastNameController,
                          aadharController: _g2AadharController,
                          phoneController: _g2PhoneController,
                          emailController: _g2EmailController,
                          pinController: _g2PinController,
                          address1Controller: _g2Address1Controller,
                          address2Controller: _g2Address2Controller,
                          address3Controller: _g2Address3Controller,
                          selectedRelationship: _g2SelectedRelationship,
                          selectedState: _g2SelectedState,
                          selectedCity: _g2SelectedCity,
                          onRelationshipChanged: (val) =>
                              setState(() => _g2SelectedRelationship = val),
                          onStateChanged: (val) =>
                              setState(() => _g2SelectedState = val),
                          onCityChanged: (val) =>
                              setState(() => _g2SelectedCity = val),
                          // --- NEW: Add the onRemove callback ---
                          onRemove: () {
                            setState(() {
                              _showGuardian2 = false;
                              _clearGuardian2Fields(); // Clear data on collapse
                            });
                          },
                          // --- End new callback ---
                        ),
                      ],
                    ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // --- Submit Button ---
            SizedBox(
              width: screenWidth * 0.85,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.safeGreen,
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
                onPressed: _submitAndNext,
                child: const Text("Submit and Next"),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // --- Reusable Form Widget for a single Guardian ---
  Widget _buildGuardianForm({
    required BuildContext context,
    required int guardianNumber,
    required TextEditingController userIdController,
    required TextEditingController firstNameController,
    required TextEditingController lastNameController,
    required TextEditingController aadharController,
    required TextEditingController phoneController,
    required TextEditingController emailController,
    required TextEditingController pinController,
    required TextEditingController address1Controller,
    required TextEditingController address2Controller,
    required TextEditingController address3Controller,
    required String? selectedRelationship,
    required String? selectedState,
    required String? selectedCity,
    required ValueChanged<String?> onRelationshipChanged,
    required ValueChanged<String?> onStateChanged,
    required ValueChanged<String?> onCityChanged,
    final VoidCallback? onRemove, // --- NEW: Optional onRemove callback ---
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: screenWidth * 0.85,
          // --- NEW: Wrap title in a Row to add remove button ---
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Guardian $guardianNumber:",
                style: theme.textTheme.titleLarge?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // Show remove button only if callback is provided
              if (onRemove != null)
                IconButton(
                  icon: Icon(
                    Icons.remove_circle_outline,
                    color: colorScheme.error, // Use error color for removal
                  ),
                  onPressed: onRemove,
                  tooltip: "Remove Guardian 2",
                ),
            ],
          ),
        ),
        const SizedBox(height: 15),
        SizedBox(
          width: screenWidth * 0.85,
          child: _buildTextField(
            controller: userIdController,
            labelText: "User ID (if exists)",
            context: context,
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: screenWidth * 0.85,
          child: _buildTextField(
            controller: firstNameController,
            labelText: "First Name",
            context: context,
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: screenWidth * 0.85,
          child: _buildTextField(
            controller: lastNameController,
            labelText: "Last Name",
            context: context,
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: screenWidth * 0.85,
          child: _buildDropdownField(
            context: context,
            value: selectedRelationship,
            hint: "Relationship with user",
            items: _relationships,
            onChanged: onRelationshipChanged,
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: screenWidth * 0.85,
          child: _buildTextField(
            controller: aadharController,
            labelText: "AADHAR",
            context: context,
            keyboardType: TextInputType.number,
          ),
        ),
        // --- Special Note ---
        SizedBox(
          width: screenWidth * 0.85,
          child: Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 4.0, right: 4.0),
            child: Text(
              "*In the case of a minor, the AADHAR card of Guardian shall be used for e-SIM registration",
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant.withOpacity(0.8),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: screenWidth * 0.85,
          child: _buildTextField(
            controller: phoneController,
            labelText: "Phone Number",
            context: context,
            keyboardType: TextInputType.phone,
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: screenWidth * 0.85,
          child: _buildTextField(
            controller: emailController,
            labelText: "Email",
            context: context,
            keyboardType: TextInputType.emailAddress,
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: screenWidth * 0.85,
          child: _buildTextField(
            controller: pinController,
            labelText: "Pin",
            context: context,
            keyboardType: TextInputType.number,
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: screenWidth * 0.85,
          child: _buildDropdownField(
            context: context,
            value: selectedState,
            hint: "State",
            items: _states,
            onChanged: onStateChanged,
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: screenWidth * 0.85,
          child: _buildDropdownField(
            context: context,
            value: selectedCity,
            hint: "City",
            items: _cities, // This should ideally update based on state
            onChanged: onCityChanged,
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: screenWidth * 0.85,
          child: _buildTextField(
            controller: address1Controller,
            labelText: "Address line 1",
            context: context,
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: screenWidth * 0.85,
          child: _buildTextField(
            controller: address2Controller,
            labelText: "Address line 2",
            context: context,
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: screenWidth * 0.85,
          child: _buildTextField(
            controller: address3Controller,
            labelText: "Address line 3",
            context: context,
          ),
        ),
      ],
    );
  }

  // --- Step Indicator Helper ---
  Widget _buildStepIndicator(BuildContext context, {required int currentStep}) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Widget buildStep(int step) {
      final bool isActive = step == currentStep;
      final bool isCompleted = step < currentStep;

      Color boxColor = isActive
          ? AppColors.safeGreen
          : (isCompleted
                ? AppColors.safeGreen
                : colorScheme.surfaceContainerHighest);
      Color textColor = isActive
          ? Colors.white
          : (isCompleted
                ? colorScheme.onPrimary
                : colorScheme.onSurfaceVariant);

      Widget stepContent = Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: boxColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive
                ? AppColors.safeGreen
                : (isCompleted
                      ? AppColors.safeGreen
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

      // --- Make previous steps clickable ---
      if (isCompleted) {
        return GestureDetector(
          onTap: () {
            if (Navigator.canPop(context)) {
              // Pop back the required number of steps
              int stepsToPop = currentStep - step;
              for (int i = 0; i < stepsToPop; i++) {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
              }
            }
          },
          child: stepContent,
        );
      }
      return stepContent;
    }

    Widget buildLine() {
      return Container(width: 40, height: 2, color: colorScheme.outlineVariant);
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

  // --- Text Field Helper ---
  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required BuildContext context,
    TextInputType? keyboardType,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return TextField(
      controller: controller,
      style: TextStyle(color: colorScheme.onSurface),
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.5),
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

  // --- Dropdown Field Helper ---
  Widget _buildDropdownField({
    required BuildContext context,
    required String? value,
    required String hint,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: colorScheme.outlineVariant, width: 1.5),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          hint: Text(
            hint,
            style: TextStyle(color: colorScheme.onSurfaceVariant),
          ),
          icon: Icon(
            Icons.arrow_drop_down,
            color: colorScheme.onSurfaceVariant,
          ),
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurface,
          ),
          dropdownColor: colorScheme.surfaceContainerHighest,
          onChanged: onChanged,
          items: items.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(value: value, child: Text(value));
          }).toList(),
        ),
      ),
    );
  }
}
