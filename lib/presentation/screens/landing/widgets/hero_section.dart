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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Avatar with Emoji Fallback Logic ──────────────────────
          Stack(
            alignment: Alignment.center,
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: colors.primaryContainer,
                backgroundImage: detail.summary.avatarUrl != null
                    ? NetworkImage(detail.summary.avatarUrl!)
                    : null,
                child: detail.summary.avatarUrl == null
                    ? Text(
                        detail.gender == 'female' ? '👧' : '👦',
                        style: const TextStyle(fontSize: 32),
                      )
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: colors.surface,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: successColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),

          // ── Name, Mode & Subtitle Status ─────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  detail.summary.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Live Tracking',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.circle, size: 8, color: Colors.amber),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        detail.statusLabel.isNotEmpty
                            ? detail.statusLabel
                            : 'Running a little behind',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: colors.onSurfaceVariant,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Online Status, Speed & Update Time ───────────────────
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.circle, size: 8, color: successColor),
                  const SizedBox(width: 4),
                  Text(
                    'Online',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: successColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.speed_rounded, size: 16, color: colors.primary),
                  const SizedBox(width: 4),
                  const Text(
                    '18 km/h',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
              Text(
                'Travelling',
                style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant),
              ),
              const SizedBox(height: 8),
              Text(
                'Updated 8 min ago',
                style: TextStyle(
                  fontSize: 11,
                  color: colors.onSurfaceVariant.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
