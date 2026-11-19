import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../domain/entities/analytics/analytics_entity.dart';
import '../../../themes/app_text_styles.dart';
import '../../../themes/colors.dart';
import '../../../utils/app_icons.dart';
import '../../../widgets/app_surfaces.dart';
import '../../../themes/app_tokens.dart';

/// Card showing the address of the currently active analytics point
/// (works for both live and history/timeline modes).
class AddressCard extends StatelessWidget {
  final AnalyticsEntity? point;
  final bool isLoading;

  const AddressCard({super.key, required this.point, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    if (point == null && !isLoading) {
      return const SizedBox.shrink();
    }

    final address = point?.userAddress;
    final realAddress = point?.formattedAddress;
    final geofence = point?.geofenceName;
    AppLogger.d("Address card", "The address is $address");
    AppLogger.d("Address card", "The real address is $realAddress");
    AppLogger.d("Address card", "The geofence is $geofence");

    return Skeletonizer(
      enabled: isLoading,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppSize.overlayMaxWidth),
        child: AppCard(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min, // shrinks to fit short text
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: AppSpacing.sm,
            children: [
              Icon(
                AppIcons.address,
                size: AppSize.icon,
                color: AppColors.primary(context),
              ),
              Flexible(
                child: Text(
                  address ?? 'Address Unavailable',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyWithColor(
                    context,
                    color: AppColors.textPrimary(context),
                  ).copyWith(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
