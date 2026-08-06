import 'package:flutter/material.dart';
import '../../../../domain/entities/profile/profile_entity.dart';

class EmergencyContactsSection extends StatelessWidget {
  final List<GuardianEntity> guardians;

  const EmergencyContactsSection({super.key, required this.guardians});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final primary = guardians.firstWhere(
      (g) => g.isPrimary,
      orElse: () => guardians.first,
    );
    final secondary = guardians.length > 1
        ? guardians.firstWhere(
            (g) => !g.isPrimary,
            orElse: () => guardians.last,
          )
        : null;

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
          Text(
            'EMERGENCY CONTACTS',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: colors.onSurfaceVariant.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Called when this device sends SOS · two numbers max',
            style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          _ContactBox(label: 'PRIMARY', number: primary.phoneNumber),
          if (secondary != null) ...[
            const SizedBox(height: 12),
            _ContactBox(label: 'SECONDARY', number: secondary.phoneNumber),
          ],
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
