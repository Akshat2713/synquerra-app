// lib/presentation/pages/profile/widgets/guardians_section.dart

import 'package:flutter/material.dart';
import '../../../../domain/entities/profile/profile_entity.dart';

class GuardiansSection extends StatelessWidget {
  final List<GuardianEntity> guardians; // ← GuardianEntity, not GuardianItem
  final VoidCallback onSignOut;

  const GuardiansSection({
    super.key,
    required this.guardians,
    required this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          ...guardians.asMap().entries.map((entry) {
            final i = entry.key;
            final g = entry.value;
            return Column(
              children: [
                _GuardianTile(guardian: g, colors: colors),
                if (i < guardians.length - 1)
                  Divider(height: 1, indent: 16, color: colors.outlineVariant),
              ],
            );
          }),
          Divider(height: 1, color: colors.outlineVariant),
          InkWell(
            onTap: () => _confirmSignOut(context),
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Icon(Icons.logout_rounded, size: 18, color: colors.error),
                  const SizedBox(width: 10),
                  Text(
                    'Sign Out',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: colors.error,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmSignOut(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text('You will be returned to the login screen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: colors.error),
            onPressed: () {
              Navigator.pop(context);
              onSignOut();
            },
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
  }
}

class _GuardianTile extends StatelessWidget {
  final GuardianEntity guardian; // ← GuardianEntity
  final ColorScheme colors;

  const _GuardianTile({required this.guardian, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: guardian.isPrimary
                ? colors.primaryContainer
                : colors.secondaryContainer,
            child: Text(
              guardian.name.isNotEmpty ? guardian.name[0] : '?',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: guardian.isPrimary
                    ? colors.onPrimaryContainer
                    : colors.onSecondaryContainer,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  guardian.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (guardian.isPrimary)
                  Text(
                    'Primary',
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
