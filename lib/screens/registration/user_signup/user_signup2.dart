import 'package:flutter/material.dart';
import 'package:safe_track/screens/registration/user_signup/user_signup3.dart';
import 'package:safe_track/theme/colors.dart'; // Assuming AppColors.safeGreen is here
import 'package:intl/intl.dart'; // For formatting the date

// Enum for the radio buttons
enum StudentStatus { none, yes, no }

class RegistrationStep2 extends StatefulWidget {
  const RegistrationStep2({super.key});

  @override
  State<RegistrationStep2> createState() => _RegistrationStep2State();
}

class _RegistrationStep2State extends State<RegistrationStep2> {
  // Controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _dobController = TextEditingController(); // To show the selected date
  final _aadharController = TextEditingController();
  final _aaparController = TextEditingController();

  // --- NEW Controllers ---
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _pinController = TextEditingController();
  final _address1Controller = TextEditingController();
  final _address2Controller = TextEditingController();
  final _address3Controller = TextEditingController();

  // State
  String? _selectedGender;
  StudentStatus _studentStatus = StudentStatus.none;

  // --- NEW State Variables ---
  bool _useGuardianAddress = false; // For the checkbox
  String? _selectedState;
  String? _selectedCity;
  // Dummy data for dropdowns
  final List<String> _states = ['State 1', 'State 2', 'State 3'];
  final List<String> _cities = ['City 1', 'City 2', 'City 3'];

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _dobController.dispose();
    _aadharController.dispose();
    _aaparController.dispose();
    // --- Dispose new controllers ---
    _phoneController.dispose();
    _emailController.dispose();
    _pinController.dispose();
    _address1Controller.dispose();
    _address2Controller.dispose();
    _address3Controller.dispose();
    super.dispose();
  }

  // --- Date Picker Logic ---
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(
        const Duration(days: 365 * 10),
      ), // Default to 10 years ago
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dobController.text = DateFormat(
          'dd-MM-yyyy',
        ).format(picked); // Format the date
      });
    }
  }

  // --- Submit Logic ---
  void _submitAndNext() {
    // --- Basic Validation ---
    if (_firstNameController.text.isEmpty ||
        _lastNameController.text.isEmpty ||
        _dobController.text.isEmpty ||
        _selectedGender == null ||
        _aadharController.text.isEmpty ||
        _studentStatus == StudentStatus.none) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields.')),
      );
      return;
    }

    // --- Student-specific Validation ---
    if (_studentStatus == StudentStatus.yes) {
      if (_aaparController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter your AAPAR ID.')),
        );
        return;
      }
    }

    // --- NEW: Validate address fields ONLY if checkbox is unchecked (now independent of student status) ---
    if (!_useGuardianAddress) {
      if (_phoneController.text.isEmpty ||
          _emailController.text.isEmpty ||
          _pinController.text.isEmpty ||
          _selectedState == null ||
          _selectedCity == null ||
          _address1Controller.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Please fill in all address details or use Guardian\'s.',
            ),
          ),
        );
        return;
      }
    }

    // --- TODO: Implement your submission logic here ---
    print('First Name: ${_firstNameController.text}');
    print('Last Name: ${_lastNameController.text}');
    print('DOB: ${_dobController.text}');
    print('Gender: $_selectedGender');
    print('AADHAR: ${_aadharController.text}');
    print('Is Student: $_studentStatus');
    if (_studentStatus == StudentStatus.yes) {
      print('AAPAR: ${_aaparController.text}');
    }
    print('Using Guardian Address: $_useGuardianAddress');
    if (!_useGuardianAddress) {
      print('Phone: ${_phoneController.text}');
      print('Email: ${_emailController.text}');
      print('PIN: ${_pinController.text}');
      print('State: $_selectedState');
      print('City: $_selectedCity');
      print('Address1: ${_address1Controller.text}');
    }

    // Navigate to the next step
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RegistrationStep3()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor, // Theme-based background
      appBar: AppBar(
        title: const Text("User Details"),
        backgroundColor: theme.appBarTheme.backgroundColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // --- Step Indicator ---
            _buildStepIndicator(context, currentStep: 2),
            const SizedBox(height: 30),

            // --- Title ---
            Text(
              "User Details",
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
                decorationColor: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 30),

            // --- Form Fields ---
            SizedBox(
              width: screenWidth * 0.85,
              child: _buildTextField(
                controller: _firstNameController,
                labelText: "First Name",
                context: context,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: screenWidth * 0.85,
              child: _buildTextField(
                controller: _lastNameController,
                labelText: "Last Name",
                context: context,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: screenWidth * 0.85,
              child: _buildTextField(
                controller: _dobController,
                labelText: "DOB",
                context: context,
                readOnly: true,
                onTap: () => _selectDate(context),
                suffixIcon: Icon(
                  Icons.calendar_month,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: screenWidth * 0.85,
              child: _buildDropdownField(
                context: context,
                value: _selectedGender,
                hint: "Gender",
                items: ['Male', 'Female', 'Other'],
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedGender = newValue;
                  });
                },
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: screenWidth * 0.85,
              child: _buildTextField(
                controller: _aadharController,
                labelText: "AADHAR",
                context: context,
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(height: 30),

            // --- Student Section ---
            SizedBox(
              width: screenWidth * 0.85,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Applying as a student?",
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Row(
                    children: [
                      Radio<StudentStatus>(
                        value: StudentStatus.yes,
                        groupValue: _studentStatus,
                        onChanged: (StudentStatus? value) {
                          setState(() {
                            _studentStatus = value!;
                          });
                        },
                        activeColor: AppColors.safeGreen,
                      ),
                      Text(
                        "Yes",
                        style: TextStyle(color: colorScheme.onSurface),
                      ),
                      const SizedBox(width: 20),
                      Radio<StudentStatus>(
                        value: StudentStatus.no,
                        groupValue: _studentStatus,
                        onChanged: (StudentStatus? value) {
                          setState(() {
                            _studentStatus = value!;
                          });
                        },
                        activeColor: AppColors.safeGreen,
                      ),
                      Text(
                        "No",
                        style: TextStyle(color: colorScheme.onSurface),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // --- Conditional AAPAR Field ---
            if (_studentStatus == StudentStatus.yes)
              SizedBox(
                width: screenWidth * 0.85,
                child: _buildTextField(
                  controller: _aaparController,
                  labelText: "AAPAR",
                  context: context,
                  keyboardType: TextInputType.number,
                ),
              ),
            if (_studentStatus == StudentStatus.yes) const SizedBox(height: 20),

            // --- Guardian Address Section ---
            SizedBox(
              width: screenWidth * 0.85,
              // --- NEW CONTAINER WRAPPER ---
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceVariant, // As requested
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // --- "Use same as Guardian's" Checkbox ---
                    CheckboxListTile(
                      title: Text(
                        "Use same as Guardian's",
                        style: TextStyle(color: colorScheme.onSurface),
                      ),
                      value: _useGuardianAddress,
                      onChanged: (bool? value) {
                        setState(() {
                          _useGuardianAddress = value!;
                        });
                      },
                      activeColor: AppColors.safeGreen,
                      controlAffinity:
                          ListTileControlAffinity.leading, // Checkbox on left
                      contentPadding: EdgeInsets.zero,
                    ),

                    // --- Collapsible Address Container ---
                    AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child: Container(
                        child: _useGuardianAddress
                            ? const SizedBox(height: 0) // Collapsed state
                            : Column(
                                // Expanded state
                                children: [
                                  const SizedBox(height: 12), // Spacer
                                  _buildTextField(
                                    controller: _phoneController,
                                    labelText: "Phone Number",
                                    context: context,
                                    keyboardType: TextInputType.phone,
                                  ),
                                  const SizedBox(height: 20),
                                  _buildTextField(
                                    controller: _emailController,
                                    labelText: "Email",
                                    context: context,
                                    keyboardType: TextInputType.emailAddress,
                                  ),
                                  const SizedBox(height: 20),
                                  _buildTextField(
                                    controller: _pinController,
                                    labelText: "Pin",
                                    context: context,
                                    keyboardType: TextInputType.number,
                                  ),
                                  const SizedBox(height: 20),
                                  _buildDropdownField(
                                    context: context,
                                    value: _selectedState,
                                    hint: "State",
                                    items: _states,
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        _selectedState = newValue;
                                        // TODO: Add logic to update cities based on state
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 20),
                                  _buildDropdownField(
                                    context: context,
                                    value: _selectedCity,
                                    hint: "City",
                                    items:
                                        _cities, // TODO: This list should update based on state
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        _selectedCity = newValue;
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 20),
                                  _buildTextField(
                                    controller: _address1Controller,
                                    labelText: "Address line 1",
                                    context: context,
                                  ),
                                  const SizedBox(height: 20),
                                  _buildTextField(
                                    controller: _address2Controller,
                                    labelText: "Address line 2",
                                    context: context,
                                  ),
                                  const SizedBox(height: 20),
                                  _buildTextField(
                                    controller: _address3Controller,
                                    labelText: "Address line 3",
                                    context: context,
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40), // Spacer before button
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

  // Helper widget for the step indicator
  Widget _buildStepIndicator(BuildContext context, {required int currentStep}) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Widget buildStep(int step) {
      final bool isActive = step == currentStep;
      final bool isCompleted = step < currentStep;

      Color boxColor = isActive
          ? AppColors.safeGreen
          : (isCompleted ? AppColors.safeGreen : colorScheme.surfaceVariant);
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

      // If step 1 (completed), make it clickable
      if (step == 1 && isCompleted) {
        return GestureDetector(
          onTap: () {
            // Navigate back to the previous screen
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
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

  // Helper widget for a styled text field
  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required BuildContext context,
    bool readOnly = false,
    VoidCallback? onTap,
    Icon? suffixIcon,
    TextInputType? keyboardType,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return TextField(
      controller: controller,
      style: TextStyle(color: colorScheme.onSurface),
      readOnly: readOnly,
      onTap: onTap,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        filled: true,
        // CHANGED: Use a different fill color so it stands out on surfaceVariant
        fillColor: colorScheme.surface.withOpacity(0.5),
        suffixIcon: suffixIcon,
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

  // Helper widget for styled DropdownButton
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
        // CHANGED: Use a different fill color so it stands out on surfaceVariant
        color: colorScheme.surface.withOpacity(0.5),
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
          dropdownColor: colorScheme.surfaceVariant,
          onChanged: onChanged,
          items: items.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(value: value, child: Text(value));
          }).toList(),
        ),
      ),
    );
  }
}
