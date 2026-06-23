import 'package:flutter/material.dart';
import '../../../blocs/landing/landing_bloc.dart';

class HeroSection extends StatelessWidget {
  final MemberDetail detail;
  final Color successColor;

  const HeroSection({
    super.key,
    required this.detail,
    this.successColor = const Color(0xFF3DDC84),
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: successColor, width: 2.5),
                boxShadow: [
                  BoxShadow(
                    color: successColor.withOpacity(0.35),
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
            CircleAvatar(
              radius: 40,
              backgroundColor: colors.surfaceContainerHighest,
              backgroundImage: detail.summary.avatarUrl != null
                  ? NetworkImage(detail.summary.avatarUrl!)
                  : null,
              child: detail.summary.avatarUrl == null
                  ? Text(
                      detail.gender == 'female' ? '👧' : '👦',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        color: colors.onSurfaceVariant,
                      ),
                    )
                  : null,
            ),
            Positioned(
              bottom: 6,
              right: 6,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: successColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: colors.surface, width: 2),
                ),
                child: const Icon(Icons.check, size: 11, color: Colors.white),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          detail.summary.name,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              detail.statusLabel,
              style: TextStyle(fontSize: 14, color: colors.onSurfaceVariant),
            ),
            const SizedBox(width: 6),
            const Text('🔵', style: TextStyle(fontSize: 13)),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: colors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: successColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'Verified ${detail.verifiedAgo}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
