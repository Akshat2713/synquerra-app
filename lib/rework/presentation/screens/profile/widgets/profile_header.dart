// lib/presentation/pages/profile/widgets/profile_header.dart

import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  final String fullName;
  final String roleBadge;
  final bool isPro;

  const ProfileHeader({
    super.key,
    required this.fullName,
    required this.roleBadge,
    required this.isPro,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: colors.primaryContainer,
          child: Text(
            fullName.isNotEmpty ? fullName[0] : '?',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: colors.onPrimaryContainer,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              fullName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  roleBadge,
                  style: TextStyle(
                    fontSize: 13,
                    color: colors.onSurfaceVariant,
                  ),
                ),
                if (isPro) ...[
                  const SizedBox(width: 8),
                  _ProBadge(colors: colors),
                ],
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _ProBadge extends StatelessWidget {
  final ColorScheme colors;
  const _ProBadge({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: colors.tertiaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded, size: 12, color: colors.tertiary),
          const SizedBox(width: 3),
          Text(
            'Pro',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: colors.tertiary,
            ),
          ),
        ],
      ),
    );
  }
}
