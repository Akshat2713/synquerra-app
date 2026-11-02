import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../themes/app_text_styles.dart';
import '../themes/app_tokens.dart';
import '../themes/colors.dart';
import '../utils/app_icons.dart';
import '../utils/date_time_formatter.dart';
import 'app_motion_widgets.dart';
import 'app_overlays.dart';
import 'app_section_card.dart';
import 'app_surfaces.dart';
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
    if (picked != null && mounted) {
      setState(() => c.profilePhoto = picked.path);
    }
  }

  void _showPhotoSourceSheet() {
    showAppBottomSheet(
      context,
      builder: (sheetContext) => Padding(
        padding: AppSpacing.mdAll,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _PhotoOption(
              icon: AppIcons.camera,
              label: 'Take Photo',
              background: AppColors.primary(context),
              foreground: AppColors.onPrimary(context),
              onTap: () {
                Navigator.pop(sheetContext);
                _pickImage(ImageSource.camera);
              },
            ),
            _PhotoOption(
              icon: AppIcons.gallery,
              label: 'Choose from Gallery',
              background: AppColors.info,
              foreground: AppColors.onInfo,
              onTap: () {
                Navigator.pop(sheetContext);
                _pickImage(ImageSource.gallery);
              },
            ),
            if (c.profilePhoto?.isNotEmpty ?? false)
              _PhotoOption(
                icon: AppIcons.delete,
                label: 'Remove Photo',
                background: AppColors.danger,
                foreground: AppColors.onDanger,
                onTap: () {
                  Navigator.pop(sheetContext);
                  setState(() => c.profilePhoto = null);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    final image = c.avatarImage;
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: AppSize.avatarLg / 2,
            backgroundColor: AppColors.primaryContainer(context),
            backgroundImage: image,
            child: image == null
                ? Icon(
                    AppIcons.person,
                    size: AppSize.tapTarget,
                    color: AppColors.onPrimaryContainer(context),
                  )
                : null,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Tooltip(
              message: 'Change photo',
              child: IconTile(
                circle: true,
                size: AppSize.avatarSm,
                background: AppColors.primary(context),
                foreground: AppColors.onPrimary(context),
                child: Material(
                  type: MaterialType.transparency,
                  shape: const CircleBorder(),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      _showPhotoSourceSheet();
                    },
                    child: Center(
                      child: Icon(
                        AppIcons.camera,
                        size: AppSize.iconSm,
                        color: AppColors.onPrimary(context),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectBirthDate() async {
    // TODO(logic): date bounds (1900 / today / 2000 default) are business rules.
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: c.birthDate ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && mounted) {
      setState(() {
        c.birthDate = picked;
        c.birthDateController.text = DateTimeFormatter.formatDate(picked);
      });
    }
  }

  Widget _prefix(IconData icon) =>
      Icon(icon, size: AppSize.icon, color: AppColors.textSecondary(context));

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSpacing.md,
      children: [
        _buildAvatar().entrance(context, index: 0),

        AppSectionCard(
          title: 'Personal Information',
          icon: AppIcons.person,
          background: AppColors.primary(context),
          foreground: AppColors.onPrimary(context),
          children: [
            AppTextField(
              controller: c.firstNameController,
              label: 'First Name *',
              hint: 'Anik',
              prefixIcon: AppIcons.person,
              validator: (v) => (v ?? '').trim().isEmpty ? 'Required' : null,
            ),
            AppTextField(
              controller: c.middleNameController,
              label: 'Middle Name',
              hint: 'M',
              prefixIcon: AppIcons.person,
            ),
            AppTextField(
              controller: c.lastNameController,
              label: 'Last Name',
              hint: 'Kumar',
              prefixIcon: AppIcons.person,
            ),
            AppTextField(
              controller: c.phoneController,
              label: 'Phone *',
              hint: '+917788997788',
              prefixIcon: AppIcons.phone,
              keyboardType: TextInputType.phone,
              validator: (v) => (v ?? '').trim().isEmpty ? 'Required' : null,
            ),
            AppTextField(
              controller: c.birthDateController,
              label: 'Birth Date',
              hint: '14 Feb, 2000',
              prefixIcon: AppIcons.date,
              readOnly: true,
              onTap: _selectBirthDate,
            ),
            DropdownButtonFormField<String>(
              initialValue: c.gender,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: 'Gender',
                prefixIcon: _prefix(AppIcons.gender),
              ),
              items: const [
                DropdownMenuItem(value: 'male', child: Text('Male')),
                DropdownMenuItem(value: 'female', child: Text('Female')),
                DropdownMenuItem(value: 'other', child: Text('Other')),
              ],
              onChanged: (val) {
                if (val != null) setState(() => c.gender = val);
              },
            ),
            if (widget.showRelationshipFields) ...[
              DropdownButtonFormField<String>(
                initialValue: c.relationshipType,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: 'Relationship',
                  prefixIcon: _prefix(AppIcons.relationship),
                ),
                items: const [
                  DropdownMenuItem(value: 'child', child: Text('Child')),
                  DropdownMenuItem(value: 'parent', child: Text('Parent')),
                  DropdownMenuItem(value: 'teacher', child: Text('Teacher')),
                  DropdownMenuItem(value: 'guardian', child: Text('Guardian')),
                  DropdownMenuItem(value: 'spouse', child: Text('Spouse')),
                  DropdownMenuItem(value: 'other', child: Text('Other')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => c.relationshipType = val);
                },
              ),
              InsetRow(
                onTap: () => setState(() => c.isHead = !c.isHead),
                child: Row(
                  spacing: AppSpacing.md,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: AppSpacing.xs,
                        children: [
                          Text(
                            'Set as Head of Family',
                            style: AppTextStyles.bodyWithColor(
                              context,
                              color: AppColors.textPrimary(context),
                            ).copyWith(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            'This member will have primary account privileges',
                            style: AppTextStyles.metaWithColor(context),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: c.isHead,
                      onChanged: (val) => setState(() => c.isHead = val),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ).entrance(context, index: 1),

        AppSectionCard(
          title: 'Account',
          icon: AppIcons.lock,
          background: AppColors.success,
          foreground: AppColors.onSuccess,
          children: [
            AppTextField(
              controller: c.emailController,
              label: 'Email *',
              hint: 'anik123@gmail.com',
              prefixIcon: AppIcons.email,
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Required';
                if (!v.contains('@')) return 'Invalid email';
                return null;
              },
            ),
            AppTextField(
              controller: c.passwordController,
              label: widget.requirePassword
                  ? 'Set Password *'
                  : 'New Password (optional)',
              hint: '••••••••',
              prefixIcon: AppIcons.lock,
              isPassword: true,
              validator: (v) {
                if (!widget.requirePassword && (v == null || v.isEmpty)) {
                  return null; // blank = keep current password
                }
                if (v == null || v.isEmpty) return 'Password is required';
                if (v.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),
            if (!widget.requirePassword)
              Padding(
                padding: AppSpacing.xsHorizontal,
                child: Text(
                  'Leave blank to keep the current password',
                  style: AppTextStyles.metaWithColor(context),
                ),
              ),
          ],
        ).entrance(context, index: 2),

        AppSectionCard(
          title: 'Address Details',
          icon: AppIcons.address,
          background: AppColors.info,
          foreground: AppColors.onInfo,
          children: [
            AppTextField(
              controller: c.addressController,
              label: 'Address',
              hint: 'XYZ Colony, ABC Road',
              prefixIcon: AppIcons.street,
            ),
            AppTextField(
              controller: c.cityController,
              label: 'City',
              hint: 'Ranchi',
              prefixIcon: AppIcons.city,
            ),
            AppTextField(
              controller: c.stateController,
              label: 'State',
              hint: 'Jharkhand',
              prefixIcon: AppIcons.region,
            ),
            AppTextField(
              controller: c.countryController,
              label: 'Country',
              hint: 'India',
              prefixIcon: AppIcons.country,
            ),
            AppTextField(
              controller: c.pincodeController,
              label: 'Pincode',
              hint: '834003',
              prefixIcon: AppIcons.pincode,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
            ),
          ],
        ).entrance(context, index: 3),
      ],
    );
  }
}

class _PhotoOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color background;
  final Color foreground;
  final VoidCallback onTap;

  const _PhotoOption({
    required this.icon,
    required this.label,
    required this.background,
    required this.foreground,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InsetRow(
      onTap: onTap,
      child: Row(
        spacing: AppSpacing.smd,
        children: [
          IconTile(icon: icon, background: background, foreground: foreground),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.bodyWithColor(
                context,
                color: AppColors.textPrimary(context),
              ).copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
