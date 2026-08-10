import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../../domain/entities/analytics/analytics_entity.dart';

/// Card showing the address of the currently active analytics point
/// (works for both live and history/timeline modes).
class AddressCard extends StatelessWidget {
  final AnalyticsEntity? point;
  final bool isLoading;

  const AddressCard({super.key, required this.point, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    if (point == null && !isLoading) {
      return const SizedBox.shrink();
    }

    final address = point?.formattedAddress;
    final geofence = point?.geofenceName;

    return Skeletonizer(
      enabled: isLoading,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 320),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.location_on_rounded, size: 18, color: colors.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                address ?? geofence ?? 'Address Unavailable',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: colors.onSurface,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
