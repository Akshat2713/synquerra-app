// lib/presentation/screens/manage/widgets/emergency_contacts_section.dart

import 'package:flutter/material.dart';
import '../../../../domain/entities/settings/settings_entity.dart';
import '../../../themes/colors.dart';
import 'package:synquerra/presentation/themes/app_tokens.dart';

class EmergencyContactsSection extends StatelessWidget {
  final String deviceId;
  final SettingsEntity settings;
  final bool isUpdating;
  final void Function(String phoneNum1, String phoneNum2)? onSaveContacts;

  const EmergencyContactsSection({
    super.key,
    required this.deviceId,
    required this.settings,
    this.isUpdating = false,
    this.onSaveContacts,
  });

  void _showEditBottomSheet(BuildContext context) {
    final primaryController = TextEditingController(
      text: settings.phoneNum1 == 'No Primary Number' ? '' : settings.phoneNum1,
    );
    final secondaryController = TextEditingController(
      text: settings.phoneNum2 == 'No Secondary Number'
          ? ''
          : settings.phoneNum2,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomSheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(bottomSheetContext).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Edit Emergency Contacts',
                    style: TextStyle(
                      color: AppColors.textPrimary(
                        context,
                      ).withValues(alpha: AppAlpha.overlay),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(bottomSheetContext),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: primaryController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Primary Phone Number',
                  prefixIcon: Icon(Icons.phone_rounded),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: secondaryController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Secondary Phone Number',
                  prefixIcon: Icon(Icons.phone_outlined),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary(context),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.mdAll,
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(bottomSheetContext);
                    onSaveContacts?.call(
                      primaryController.text.trim(),
                      secondaryController.text.trim(),
                    );
                  },
                  child: const Text(
                    'Save Contacts',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: AppRadius.lgAll,
        border: Border.all(
          color: AppColors.outline(context).withValues(alpha: AppAlpha.overlay),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'EMERGENCY CONTACTS',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: AppColors.textPrimary(context).withValues(alpha: AppAlpha.overlay),
                ),
              ),
              if (isUpdating)
                const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator.adaptive(strokeWidth: 2),
                )
              else
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: Icon(
                    Icons.edit_rounded,
                    size: 18,
                    color: AppColors.primary(context),
                  ),
                  onPressed: () => _showEditBottomSheet(context),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Called when this device sends SOS · two numbers max',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary(context),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _ContactBox(
            label: 'PRIMARY',
            number: settings.phoneNum1 ?? 'No Primary Number',
          ),
          const SizedBox(height: 12),
          _ContactBox(
            label: 'SECONDARY',
            number: settings.phoneNum2 ?? 'No Secondary Number',
          ),
        ],
      ),
    );
  }
}

class _ContactBox extends StatelessWidget {
  final String label;
  final String number;

  const _ContactBox({required this.label, required this.number});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary(context).withValues(alpha: AppAlpha.overlay),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant(context).withValues(alpha: AppAlpha.border),
            borderRadius: AppRadius.mdAll,
          ),
          child: Text(
            number,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }
}
