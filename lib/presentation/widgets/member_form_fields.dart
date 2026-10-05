import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../themes/colors.dart';
import '../utils/date_time_formatter.dart';
import 'app_text_field.dart';
import 'member_form_controller.dart';

class MemberFormFields extends StatefulWidget {
  final MemberFormController controller;
  final bool requirePassword;
  final bool showRelationshipFields;

  const MemberFormFields({
    super.key,
    required this.controller,
    this.requirePassword = true,
    this.showRelationshipFields = true,
  });

  @override
  State<MemberFormFields> createState() => _MemberFormFieldsState();
}

class _MemberFormFieldsState extends State<MemberFormFields> {
  final _picker = ImagePicker();

  MemberFormController get c => widget.controller;

  Future<void> _pickImage(ImageSource source) async {
    final XFile? picked = await _picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 1024,
    );
    if (picked != null) {
      setState(
        () => c.profilePhoto = picked.path,
      ); // was: c.newProfileImage = File(picked.path)
    }
  }

  void _showPhotoSourceSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text('Take Photo'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _pickImage(ImageSource.gallery);
                },
              ),
              if (c.profilePhoto?.isNotEmpty ?? false)
                ListTile(
                  leading: Icon(Icons.delete_outline, color: AppColors.danger),
                  title: Text(
                    'Remove Photo',
                    style: TextStyle(color: AppColors.danger),
                  ),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    setState(() => c.profilePhoto = null); //
                  },
                ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAvatar() {
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 52,
            backgroundColor: AppColors.outlineVariant(context),
            backgroundImage: c.avatarImage, // was: image (locally built)
            child:
                c.avatarImage ==
                    null // was: image == null
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
            child: GestureDetector(
              onTap: _showPhotoSourceSheet,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary(context),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.camera_alt_outlined,
                  size: 18,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectBirthDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: c.birthDate ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        c.birthDate = picked;
        c.birthDateController.text = DateTimeFormatter.formatDate(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildAvatar(),
        const SizedBox(height: 24),
        AppTextField(
          controller: c.firstNameController,
          label: 'First Name *',
          hint: 'Anik',
          prefixIcon: Icons.person_outline,
          validator: (v) => v!.trim().isEmpty ? 'Required' : null,
        ),
        const SizedBox(height: 16),
        AppTextField(
          controller: c.middleNameController,
          label: 'Middle Name',
          hint: 'M',
          prefixIcon: Icons.person_outline,
        ),
        const SizedBox(height: 16),
        AppTextField(
          controller: c.lastNameController,
          label: 'Last Name',
          hint: 'Kumar',
          prefixIcon: Icons.person_outline,
        ),
        const SizedBox(height: 16),
        AppTextField(
          controller: c.emailController,
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
          controller: c.passwordController,
          label: widget.requirePassword
              ? 'Set Password *'
              : 'New Password (optional)',
          hint: '••••••••',
          prefixIcon: Icons.lock_outline_rounded,
          isPassword: true,
          validator: (v) {
            if (!widget.requirePassword && (v == null || v.isEmpty)) {
              return null; // blank = keep current password
            }
            if (v == null || v.isEmpty) return 'Password is required';
            if (v.length < 6) return 'Password must be at least 6 characters';
            return null;
          },
        ),
        if (!widget.requirePassword)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4),
            child: Text(
              'Leave blank to keep the current password',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary(context),
              ),
            ),
          ),
        const SizedBox(height: 16),
        AppTextField(
          controller: c.phoneController,
          label: 'Phone *',
          hint: '+917788997788',
          prefixIcon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          validator: (v) => v!.trim().isEmpty ? 'Required' : null,
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: _selectBirthDate,
          child: AbsorbPointer(
            child: AppTextField(
              controller: c.birthDateController,
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
          initialValue: c.gender,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.outlineVariant(context)),
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
          onChanged: (val) => setState(() => c.gender = val!),
        ),
        const SizedBox(height: 16),
        Text(
          'Relationship',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary(context),
          ),
        ),
        const SizedBox(height: 6),
        if (widget.showRelationshipFields) ...[
          DropdownButtonFormField<String>(
            initialValue: c.relationshipType,
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
            onChanged: (val) => setState(() => c.relationshipType = val!),
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
            value: c.isHead,
            onChanged: (val) => setState(() => c.isHead = val),
            activeThumbColor: AppColors.primary(context),
            contentPadding: EdgeInsets.zero,
          ),
        ],
        const SizedBox(height: 16),

        AppTextField(
          controller: c.addressController,
          label: 'Address',
          hint: 'XYZ Colony, ABC Road',
          prefixIcon: Icons.home_outlined,
        ),
        const SizedBox(height: 16),
        AppTextField(
          controller: c.cityController,
          label: 'City',
          hint: 'Ranchi',
          prefixIcon: Icons.location_city_outlined,
        ),
        const SizedBox(height: 16),
        AppTextField(
          controller: c.stateController,
          label: 'State',
          hint: 'Jharkhand',
          prefixIcon: Icons.map_outlined,
        ),
        const SizedBox(height: 16),
        AppTextField(
          controller: c.countryController,
          label: 'Country',
          hint: 'India',
          prefixIcon: Icons.flag_outlined,
        ),
        const SizedBox(height: 16),
        AppTextField(
          controller: c.pincodeController,
          label: 'Pincode',
          hint: '834003',
          prefixIcon: Icons.pin_outlined,
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }
}
