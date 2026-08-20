// lib/presentation/screens/manage/widgets/emergency_contacts_section.dart

import 'package:flutter/material.dart';
import '../../../../domain/entities/settings/settings_entity.dart';

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

    final colors = Theme.of(context).colorScheme;

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
                  const Text(
                    'Edit Emergency Contacts',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: colors.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
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
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.3)),
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
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: colors.onSurfaceVariant.withValues(alpha: 0.6),
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
                    color: colors.primary,
                  ),
                  onPressed: () => _showEditBottomSheet(context),
                ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            'Called when this device sends SOS · two numbers max',
            style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
          ),
          const SizedBox(height: 14),
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
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: colors.onSurfaceVariant.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: colors.surfaceContainerHighest.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(12),
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
