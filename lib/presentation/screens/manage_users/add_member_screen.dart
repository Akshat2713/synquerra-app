import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/manage_users/manage_users_bloc.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/app_button.dart';
import '../../utils/date_time_formatter.dart';

class AddMemberScreen extends StatefulWidget {
  const AddMemberScreen({super.key});

  @override
  State<AddMemberScreen> createState() => _AddMemberScreenState();
}

class _AddMemberScreenState extends State<AddMemberScreen> {
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
  String _selectedRelationship = 'child';
  DateTime? _selectedBirthDate;

  // Tracks whether the in-flight submission belongs to this screen, so the
  // listener doesn't react to isAdding changes triggered elsewhere.
  bool _wasSubmitting = false;

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
    _wasSubmitting = true;
    context.read<ManageUsersBloc>().add(
      ManageUsersAddRequested(
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
        relationshipType: _selectedRelationship,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return BlocConsumer<ManageUsersBloc, ManageUsersState>(
      listener: (context, state) {
        if (state is ManageUsersLoaded && _wasSubmitting && !state.isAdding) {
          _wasSubmitting = false;
          if (state.errorMessage == null) {
            Navigator.pop(context, true);
          } else {
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
        }
      },
      builder: (context, state) {
        final isAdding = state is ManageUsersLoaded && state.isAdding;
        return Scaffold(
          backgroundColor: colors.surface,
          appBar: AppBar(
            title: const Text('Add Family Member'),
            centerTitle: false,
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppTextField(
                      controller: _firstNameController,
                      label: 'First Name *',
                      hint: 'Anik',
                      prefixIcon: Icons.person_outline,
                      validator: (v) => v!.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _lastNameController,
                      label: 'Last Name',
                      hint: 'Kumar',
                      prefixIcon: Icons.person_outline,
                    ),
                    const SizedBox(height: 16),
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
                    AppTextField(
                      controller: _phoneController,
                      label: 'Phone *',
                      hint: '+917788997788',
                      prefixIcon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: (v) => v!.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
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
                      initialValue: _selectedGender,
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
                        DropdownMenuItem(
                          value: 'female',
                          child: Text('Female'),
                        ),
                        DropdownMenuItem(value: 'other', child: Text('Other')),
                      ],
                      onChanged: (val) =>
                          setState(() => _selectedGender = val!),
                    ),
                    const SizedBox(height: 16),
                    // ── Relationship ──────────────────────────────
                    Text(
                      'Relationship *',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: colors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedRelationship,
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
                          Icons.diversity_3_outlined,
                          color: colors.onSurfaceVariant,
                          size: 20,
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'child', child: Text('Child')),
                        DropdownMenuItem(
                          value: 'parent',
                          child: Text('Parent'),
                        ),
                      ],
                      onChanged: (val) =>
                          setState(() => _selectedRelationship = val!),
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _addressController,
                      label: 'Address',
                      hint: 'XYZ Colony, ABC Road',
                      prefixIcon: Icons.home_outlined,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _cityController,
                      label: 'City',
                      hint: 'Ranchi',
                      prefixIcon: Icons.location_city_outlined,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _stateController,
                      label: 'State',
                      hint: 'Jharkhand',
                      prefixIcon: Icons.map_outlined,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _countryController,
                      label: 'Country',
                      hint: 'India',
                      prefixIcon: Icons.flag_outlined,
                    ),
                    const SizedBox(height: 16),
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
                            'Cancel',
                            style: TextStyle(color: colors.onSurfaceVariant),
                          ),
                        ),
                        SizedBox(
                          width: 200,
                          child: AppButton(
                            label: 'Add Member',
                            onPressed: _submit,
                            isLoading: isAdding,
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
      },
    );
  }
}
