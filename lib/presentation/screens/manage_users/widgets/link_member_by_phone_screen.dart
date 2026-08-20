import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../app/app_router.dart';
import '../../../blocs/manage_users/manage_users_bloc.dart';
import '../../../themes/colors.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_text_field.dart';

class LinkMemberByPhoneBottomSheet extends StatefulWidget {
  const LinkMemberByPhoneBottomSheet({super.key});

  /// Helper to display this bottom sheet from any screen
  static Future<void> show(BuildContext context) {
    final bloc = context.read<ManageUsersBloc>();

    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: bloc,
        child: const LinkMemberByPhoneBottomSheet(),
      ),
    );
  }

  @override
  State<LinkMemberByPhoneBottomSheet> createState() =>
      _LinkMemberByPhoneBottomSheetState();
}

class _LinkMemberByPhoneBottomSheetState
    extends State<LinkMemberByPhoneBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  String _selectedRelationship = 'Friend';

  final List<String> _relationshipTypes = [
    'Friend',
    'Parent',
    'Child',
    'Sibling',
    'Spouse',
    'Relative',
    'Other',
  ];

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<ManageUsersBloc>().add(
      ManageUsersLinkByPhoneRequested(
        phoneNumber: _phoneController.text.trim(),
        relationshipType: _selectedRelationship,
      ),
    );
    Navigator.pop(context);
  }

  void _navigateToCreateUser() {
    final bloc = context.read<ManageUsersBloc>();
    // Dismiss the bottom sheet first
    Navigator.pop(context);

    // Open add member screen
    Navigator.pushNamed(context, AppRoutes.addMember, arguments: bloc);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(24, 12, 24, bottomInset + 24),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: AppColors.textSecondary(
                      context,
                    ).withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Link Member',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary(context),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                    visualDensity: VisualDensity.compact,
                    color: AppColors.textSecondary(context),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Enter the registered phone number of the member you want to link.',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary(context),
                ),
              ),
              const SizedBox(height: 20),

              // Phone Number Input
              AppTextField(
                controller: _phoneController,
                label: 'Phone Number *',
                hint: '+917878787878',
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Phone number is required';
                  }
                  if (v.trim().length < 10) {
                    return 'Enter a valid phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Relationship Dropdown
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
                value: _selectedRelationship,
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
                items: _relationshipTypes
                    .map(
                      (type) =>
                          DropdownMenuItem(value: type, child: Text(type)),
                    )
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedRelationship = val);
                  }
                },
              ),
              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: AppButton(label: 'Link Member', onPressed: _submit),
              ),
              const SizedBox(height: 16),

              // Navigate to Create User Link
              Center(
                child: RichText(
                  text: TextSpan(
                    text: "Can't find them? ",
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary(context),
                    ),
                    children: [
                      TextSpan(
                        text: 'Create a user',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = _navigateToCreateUser,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
