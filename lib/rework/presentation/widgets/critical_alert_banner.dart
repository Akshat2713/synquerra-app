import 'package:flutter/material.dart';

class CriticalAlertBanner extends StatelessWidget {
  final int criticalCount;
  final int devicesNeedingAttention;
  final VoidCallback? onTap;

  const CriticalAlertBanner({
    super.key,
    required this.criticalCount,
    required this.devicesNeedingAttention,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (criticalCount == 0) return const SizedBox.shrink();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFEBEB),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFFF4444), width: 1.2),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFF4444).withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.warning_rounded,
                color: Color(0xFFFF4444),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$criticalCount device${criticalCount > 1 ? 's' : ''} need${criticalCount == 1 ? 's' : ''} attention',
                    style: const TextStyle(
                      color: Color(0xFFCC0000),
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$criticalCount critical alert${criticalCount > 1 ? 's' : ''} unacknowledged',
                    style: TextStyle(
                      color: const Color(0xFFCC0000).withOpacity(0.75),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFFCC0000)),
          ],
        ),
      ),
    );
  }
}
