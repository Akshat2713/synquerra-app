import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../app/app_router.dart';
import '../../blocs/signup/signup_bloc.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/app_button.dart';
import '../../utils/date_time_formatter.dart';
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

  Future<void> _selectBirthDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedBirthDate = picked;
        _birthDateController.text = DateTimeFormatter.formatDate(picked);
      });
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    context.read<SignupBloc>().add(
      SignupProfileSubmitted(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        birthDate: _selectedBirthDate != null
            ? DateTimeFormatter.toIsoString(_selectedBirthDate!)
            : '',
        gender: _selectedGender,
        address: _addressController.text.trim(),
        city: _cityController.text.trim(),
        state: _stateController.text.trim(),
        country: _countryController.text.trim(),
        pincode: _pincodeController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return BlocListener<SignupBloc, SignupState>(
      listener: (context, state) {
        // Navigate to screen 2 when step 1 succeeds
        if (state.status == SignupStatus.stepSuccess && state.step == 2) {
          Navigator.pushNamed(context, AppRoutes.signupCredentials);
        }

        // Show error snackbar
        if (state.status == SignupStatus.error && state.errorMessage != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: colors.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
        }
      },
      child: Scaffold(
        backgroundColor: colors.surface,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Page Header ──────────────────────────────
                  Center(
                    child: Text(
                      'Create Your Account',
                      style: textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colors.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Center(
                    child: Text(
                      'Register your profile, secure your account, and connect your smart device in three simple steps.',
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ── Progress Tracker ─────────────────────────
                  // remove _buildProgressTracker(colors) call, replace with:
                  const SignupProgressTracker(currentStep: SignupStep.profile),
                  const SizedBox(height: 32),

                  // ── First Name ────────────────────────────────
                  AppTextField(
                    controller: _firstNameController,
                    label: 'First Name *',
                    hint: 'Anik',
                    prefixIcon: Icons.person_outline,
                    validator: (v) => v!.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),

                  // ── Last Name ─────────────────────────────────
                  AppTextField(
                    controller: _lastNameController,
                    label: 'Last Name',
                    hint: 'Kumar',
                    prefixIcon: Icons.person_outline,
                  ),
                  const SizedBox(height: 16),

                  // ── Email ─────────────────────────────────────
                  AppTextField(
                    controller: _emailController,
                    label: 'Email *',
                    hint: 'anik123@gmail.com',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Required';
                      if (!v.contains('@')) return 'Invalid email';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // ── Phone ─────────────────────────────────────
                  AppTextField(
                    controller: _phoneController,
                    label: 'Phone *',
                    hint: '+917788997788',
                    prefixIcon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    validator: (v) => v!.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),

                  // ── Birth Date ────────────────────────────────
                  GestureDetector(
                    onTap: () => _selectBirthDate(context),
                    child: AbsorbPointer(
                      child: AppTextField(
                        controller: _birthDateController,
                        label: 'Birth Date',
                        hint: '14 Feb, 2000',
                        prefixIcon: Icons.calendar_today_outlined,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Gender ────────────────────────────────────
                  Text(
                    'Gender',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: colors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: _selectedGender,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: colors.outlineVariant),
                      ),
                      prefixIcon: Icon(
                        Icons.wc_outlined,
                        color: colors.onSurfaceVariant,
                        size: 20,
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'male', child: Text('Male')),
                      DropdownMenuItem(value: 'female', child: Text('Female')),
                      DropdownMenuItem(value: 'other', child: Text('Other')),
                    ],
                    onChanged: (val) => setState(() => _selectedGender = val!),
                  ),
                  const SizedBox(height: 16),

                  // ── Address ───────────────────────────────────
                  AppTextField(
                    controller: _addressController,
                    label: 'Address',
                    hint: 'XYZ Colony, ABC Road',
                    prefixIcon: Icons.home_outlined,
                  ),
                  const SizedBox(height: 16),

                  // ── City ──────────────────────────────────────
                  AppTextField(
                    controller: _cityController,
                    label: 'City',
                    hint: 'Ranchi',
                    prefixIcon: Icons.location_city_outlined,
                  ),
                  const SizedBox(height: 16),

                  // ── State ─────────────────────────────────────
                  AppTextField(
                    controller: _stateController,
                    label: 'State',
                    hint: 'Jharkhand',
                    prefixIcon: Icons.map_outlined,
                  ),
                  const SizedBox(height: 16),

                  // ── Country ───────────────────────────────────
                  AppTextField(
                    controller: _countryController,
                    label: 'Country',
                    hint: 'India',
                    prefixIcon: Icons.flag_outlined,
                  ),
                  const SizedBox(height: 16),

                  // ── Pincode ───────────────────────────────────
                  AppTextField(
                    controller: _pincodeController,
                    label: 'Pincode',
                    hint: '834003',
                    prefixIcon: Icons.pin_outlined,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 32),

                  // ── Footer ────────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Back to Login',
                          style: TextStyle(color: colors.onSurfaceVariant),
                        ),
                      ),
                      BlocBuilder<SignupBloc, SignupState>(
                        builder: (context, state) {
                          return SizedBox(
                            width: 200,
                            child: AppButton(
                              label: 'Next: Account Setup',
                              onPressed: _submit,
                              isLoading: state.status == SignupStatus.loading,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
