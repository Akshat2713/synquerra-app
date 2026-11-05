import 'package:flutter/material.dart';
import '../../../domain/entities/signup/signup_profile_data.dart';
import '../../app/app_router.dart';
import '../../themes/app_text_styles.dart';
import '../../themes/app_tokens.dart';
import '../../themes/colors.dart';
import '../../utils/app_icons.dart';
import '../../utils/date_time_formatter.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_dropdown_field.dart';
import '../../widgets/app_motion_widgets.dart';
import '../../widgets/app_section_card.dart';
import '../../widgets/app_surfaces.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/expandable_card.dart';
import '../../widgets/signup_progress_tracker.dart';

class SignupProfileScreen extends StatefulWidget {
  const SignupProfileScreen({super.key});

  @override
  State<SignupProfileScreen> createState() => _SignupProfileScreenState();
}

class _SignupProfileScreenState extends State<SignupProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _countryController = TextEditingController();
  final _pincodeController = TextEditingController();

  String _selectedGender = 'male';
  DateTime? _selectedBirthDate; // raw DateTime for API

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _birthDateController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  Future<void> _selectBirthDate() async {
    // TODO(logic): date bounds (1900 / today / 2000 default) are business rules.
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthDate ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && mounted) {
      setState(() {
        _selectedBirthDate = picked;
        _birthDateController.text = DateTimeFormatter.formatDate(picked);
      });
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    Navigator.pushNamed(
      context,
      AppRoutes.signupCredentials,
      arguments: SignupProfileData(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        birthDate: DateTimeFormatter.toIsoString(_selectedBirthDate!),
        gender: _selectedGender,
        address: _addressController.text.trim(),
        city: _cityController.text.trim(),
        state: _stateController.text.trim(),
        country: _countryController.text.trim(),
        pincode: _pincodeController.text.trim(),
      ),
    );
  }

  // TODO(logic): validators below belong in a shared validators util
  // (required, email format, Indian phone regex).
  String? _required(String? v) => (v ?? '').trim().isEmpty ? 'Required' : null;

  String? _validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Required';
    if (!v.contains('@')) return 'Invalid email';
    return null;
  }

  String? _validatePhone(String? v) {
    if (v == null || v.trim().isEmpty) return 'Phone number is required';
    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(v.trim())) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: AppSpacing.mdAll,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: AppSpacing.md,
              children: [
                Text(
                  'Register your profile and secure your account in two simple steps.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyWithColor(context),
                ).entrance(context, index: 0),

                const SignupProgressTracker(
                  currentStep: SignupStep.profile,
                ).entrance(context, index: 1),

                AppSectionCard(
                  title: 'Personal Information',
                  icon: AppIcons.person,
                  background: AppColors.primary(context),
                  foreground: AppColors.onPrimary(context),
                  children: [
                    AppTextField(
                      controller: _firstNameController,
                      label: 'First Name *',
                      hint: 'Anik',
                      prefixIcon: AppIcons.person,
                      validator: _required,
                    ),
                    AppTextField(
                      controller: _lastNameController,
                      label: 'Last Name',
                      hint: 'Kumar',
                      prefixIcon: AppIcons.person,
                    ),

                    AppTextField(
                      controller: _birthDateController,
                      label: 'Birth Date *',
                      hint: '14 Feb, 2000',
                      prefixIcon: AppIcons.date,
                      readOnly: true,
                      onTap: _selectBirthDate,
                      validator: _required,
                    ),
                    AppDropdownField<String>(
                      label: 'Gender',
                      prefixIcon: AppIcons.gender,
                      value: _selectedGender,
                      items: const ['male', 'female', 'other'],
                      itemLabel: (g) => switch (g) {
                        'male' => 'Male',
                        'female' => 'Female',
                        _ => 'Other',
                      },
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedGender = val);
                      },
                    ),
                  ],
                ).entrance(context, index: 2),

                AppSectionCard(
                  title: 'Contact',
                  icon: AppIcons.phone,
                  background: AppColors.success,
                  foreground: AppColors.onSuccess,
                  children: [
                    AppTextField(
                      controller: _emailController,
                      label: 'Email *',
                      hint: 'anik123@gmail.com',
                      prefixIcon: AppIcons.email,
                      keyboardType: TextInputType.emailAddress,
                      validator: _validateEmail,
                    ),
                    AppTextField(
                      controller: _phoneController,
                      label: 'Phone *',
                      hint: '9876543210',
                      prefixIcon: AppIcons.phone,
                      keyboardType: TextInputType.phone,
                      validator: _validatePhone,
                    ),
                  ],
                ).entrance(context, index: 3),

                ExpandableCard(
                  title: 'Address Details',
                  leading: IconTile(
                    icon: AppIcons.address,
                    background: AppColors.info,
                    foreground: AppColors.onInfo,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: AppSpacing.md,
                    children: [
                      AppTextField(
                        controller: _addressController,
                        label: 'Address',
                        hint: 'XYZ Colony, ABC Road',
                        prefixIcon: AppIcons.street,
                      ),
                      AppTextField(
                        controller: _cityController,
                        label: 'City',
                        hint: 'Ranchi',
                        prefixIcon: AppIcons.city,
                      ),
                      AppTextField(
                        controller: _stateController,
                        label: 'State',
                        hint: 'Jharkhand',
                        prefixIcon: AppIcons.region,
                      ),
                      AppTextField(
                        controller: _countryController,
                        label: 'Country',
                        hint: 'India',
                        prefixIcon: AppIcons.country,
                      ),
                      AppTextField(
                        controller: _pincodeController,
                        label: 'Pincode',
                        hint: '834003',
                        prefixIcon: AppIcons.pincode,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                      ),
                    ],
                  ),
                ).entrance(context, index: 4),
                const SizedBox(height: AppSpacing.xs),
                AppButton(
                  label: 'Next: Account Setup',
                  onPressed: _submit,
                ).entrance(context, index: 5),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
