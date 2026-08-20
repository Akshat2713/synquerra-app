import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/entities/device/device_entity.dart';
import '../../../../domain/entities/analytics/analytics_entity.dart';
import '../../../blocs/auth/auth_bloc.dart';
import '../../../themes/colors.dart';
import '../../../utils/date_time_formatter.dart';

class HeroSection extends StatelessWidget {
  final DeviceEntity device;
  final AnalyticsEntity? latest;
  final Color successColor;

  const HeroSection({
    super.key,
    required this.device,
    this.latest,
    this.successColor = AppColors.success,
  });

  @override
  Widget build(BuildContext context) {

    // ── Resolve display name: carrier if assigned, else logged-in user ──
    final authState = context.watch<AuthBloc>().state;
    final loggedInName = authState is AuthAuthenticated
        ? authState.user.fullName
        : '—';
    final displayName = device.displayOwnerName(loggedInName);
    final isOnline = device.isOnline ?? false;
    final mode = device.currentMode;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: isOnline ? 1.0 : 0.6,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.outlineVariant(context), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Row 0: Online / Offline status, top-right ─────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(
                  Icons.circle,
                  size: 8,
                  color: isOnline ? successColor : AppColors.textSecondary(context),
                ),
                const SizedBox(width: 2),
                Text(
                  isOnline ? 'Online' : 'Offline',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: isOnline ? successColor : AppColors.textSecondary(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 3),

            // ── Avatar + info grid ──────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Avatar with Emoji Fallback Logic ─────────────────
                Stack(
                  alignment: Alignment.center,
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: AppColors.primaryContainer,
                      backgroundImage: device.carrier?.profilePhoto != null
                          ? CachedNetworkImageProvider(
                              device.carrier!.profilePhoto!,
                            )
                          : null,
                      child: device.carrier?.profilePhoto == null
                          ? Text(
                              device.carrier?.gender == 'female' ? '👧' : '👦',
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
                          color: AppColors.surface(context),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: isOnline ? successColor : Colors.grey,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 14),

                // ── Info grid: name/speed, mode/updated, alert/travel ─
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Row 1: Name (left) — Speed (right)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              displayName,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.speed_rounded,
                                size: 16,
                                color: isOnline
                                    ? AppColors.primary
                                    : AppColors.textSecondary(context),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                latest?.speed != null
                                    ? '${latest!.speed!.toStringAsFixed(0)} km/h'
                                    : '—',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),

                      // Row 2: Mode (left) — Updated at (right)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              mode,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isOnline
                                    ? AppColors.primary
                                    : AppColors.textSecondary(context),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            latest?.deviceTimestamp != null
                                ? 'Updated ${DateTimeFormatter.formatRelativeTime(latest!.deviceTimestamp)}'
                                : 'No updates yet',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary(context).withValues(
                                alpha: 0.7,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),

                      // Row 3: Recent alert (left) — Travelling/Stationary (right)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.circle,
                            size: 8,
                            color: isOnline
                                ? AppColors.warning
                                : AppColors.textSecondary(context),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              (latest?.alert != null &&
                                      latest!.alert!.isNotEmpty)
                                  ? latest!.alert!
                                  : 'No recent alerts',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary(context),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            (latest?.speed ?? 0) > 0
                                ? 'Travelling'
                                : 'Stationary',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary(context),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
