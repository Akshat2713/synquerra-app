// lib/presentation/widgets/user_form_fields.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../themes/colors.dart';
import '../utils/date_time_formatter.dart';
import 'app_text_field.dart';

class UserFormData {
  String firstName;
  String? middleName;
  String lastName;
  String email;
  String password;
  String mobile;
  DateTime? birthDate;
  String gender;
  String relationshipType;
  bool isHead;
  String address;
  String city;
  String state;
  String country;
  String pincode;
  File? profileImage;

  UserFormData({
    this.firstName = '',
    this.middleName,
    this.lastName = '',
    this.email = '',
    this.password = '',
    this.mobile = '',
    this.birthDate,
    this.gender = 'male',
    this.relationshipType = 'child',
    this.isHead = false,
    this.address = '',
    this.city = '',
    this.state = '',
    this.country = '',
    this.pincode = '',
    this.profileImage,
  });
}

class UserFormFields extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final UserFormData initialData;
  final bool showPassword;
  final bool showRelationship;
  final String submitButtonLabel;
  final bool isLoading;
  final Function(UserFormData data) onSubmit;

  const UserFormFields({
    super.key,
    required this.formKey,
    required this.initialData,
    required this.onSubmit,
    this.showPassword = true,
    this.showRelationship = true,
    required this.submitButtonLabel,
    this.isLoading = false,
  });

  @override
  State<UserFormFields> createState() => _UserFormFieldsState();
}

class _UserFormFieldsState extends State<UserFormFields> {
  late final TextEditingController _firstNameController;
  late final TextEditingController _middleNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _phoneController;
  late final TextEditingController _birthDateController;
  late final TextEditingController _addressController;
  late final TextEditingController _cityController;
  late final TextEditingController _stateController;
  late final TextEditingController _countryController;
  late final TextEditingController _pincodeController;

  late String _selectedGender;
  late String _selectedRelationship;
  late bool _isHead;
  DateTime? _selectedBirthDate;
  File? _profileImage;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final d = widget.initialData;
    _firstNameController = TextEditingController(text: d.firstName);
    _middleNameController = TextEditingController(text: d.middleName ?? '');
    _lastNameController = TextEditingController(text: d.lastName);
    _emailController = TextEditingController(text: d.email);
    _passwordController = TextEditingController(text: d.password);
    _phoneController = TextEditingController(text: d.mobile);
    _selectedBirthDate = d.birthDate;
    _birthDateController = TextEditingController(
      text: d.birthDate != null
          ? DateTimeFormatter.formatDate(d.birthDate!)
          : '',
    );
    _addressController = TextEditingController(text: d.address);
    _cityController = TextEditingController(text: d.city);
    _stateController = TextEditingController(text: d.state);
    _countryController = TextEditingController(text: d.country);
    _pincodeController = TextEditingController(text: d.pincode);

    _selectedGender = d.gender;
    _selectedRelationship = d.relationshipType;
    _isHead = d.isHead;
    _profileImage = d.profileImage;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _birthDateController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _profileImage = File(image.path));
    }
  }

  Future<void> _selectBirthDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthDate ?? DateTime(2000),
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
    if (!widget.formKey.currentState!.validate()) return;

    final data = UserFormData(
      firstName: _firstNameController.text.trim(),
      middleName: _middleNameController.text.trim().isEmpty
          ? null
          : _middleNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      mobile: _phoneController.text.trim(),
      birthDate: _selectedBirthDate,
      gender: _selectedGender,
      relationshipType: _selectedRelationship,
      isHead: _isHead,
      address: _addressController.text.trim(),
      city: _cityController.text.trim(),
      state: _stateController.text.trim(),
      country: _countryController.text.trim(),
      pincode: _pincodeController.text.trim(),
      profileImage: _profileImage,
    );

    widget.onSubmit(data);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Photo Picker
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundColor: AppColors.outlineVariant(context),
                  backgroundImage: _profileImage != null
                      ? FileImage(_profileImage!)
                      : null,
                  child: _profileImage == null
                      ? Icon(
                          Icons.person_outline,
                          size: 48,
                          color: AppColors.textSecondary(context),
                        )
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: InkWell(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: AppColors.primary,
                      child: const Icon(
                        Icons.camera_alt,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          AppTextField(
            controller: _firstNameController,
            label: 'First Name *',
            hint: 'Anik',
            prefixIcon: Icons.person_outline,
            validator: (v) => v!.trim().isEmpty ? 'Required' : null,
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: _middleNameController,
            label: 'Middle Name',
            hint: 'M',
            prefixIcon: Icons.person_outline,
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
          if (widget.showPassword) ...[
            const SizedBox(height: 16),
            AppTextField(
              controller: _passwordController,
              label: 'Set Password *',
              hint: '••••••••',
              prefixIcon: Icons.lock_outline_rounded,
              isPassword: true,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Password is required';
                if (v.length < 8) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),
          ],
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
              color: AppColors.textPrimary(context),
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
                borderSide: BorderSide(
                  color: AppColors.outlineVariant(context),
                ),
              ),
              prefixIcon: Icon(
                Icons.wc_outlined,
                color: AppColors.textSecondary(context),
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
          if (widget.showRelationship) ...[
            const SizedBox(height: 16),
            Text(
              'Relationship *',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary(context),
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
                  borderSide: BorderSide(
                    color: AppColors.outlineVariant(context),
                  ),
                ),
                prefixIcon: Icon(
                  Icons.diversity_3_outlined,
                  color: AppColors.textSecondary(context),
                  size: 20,
                ),
              ),
              items: const [
                DropdownMenuItem(value: 'child', child: Text('Child')),
                DropdownMenuItem(value: 'parent', child: Text('Parent')),
                DropdownMenuItem(value: 'teacher', child: Text('Teacher')),
                DropdownMenuItem(value: 'guardian', child: Text('Guardian')),
                DropdownMenuItem(value: 'spouse', child: Text('Spouse')),
                DropdownMenuItem(value: 'other', child: Text('Other')),
              ],
              onChanged: (val) => setState(() => _selectedRelationship = val!),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: Text(
                'Set as Head of Family',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary(context),
                ),
              ),
              subtitle: const Text(
                'This member will have primary account privileges',
              ),
              value: _isHead,
              onChanged: (val) => setState(() => _isHead = val),
              activeThumbColor: AppColors.primary,
              contentPadding: EdgeInsets.zero,
            ),
          ],
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

          // Action row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: AppColors.textSecondary(context)),
                ),
              ),
              ElevatedButton(
                onPressed: widget.isLoading ? null : _submit,
                child: widget.isLoading
                    ? const CircularProgressIndicator()
                    : Text(widget.submitButtonLabel),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
