import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/entities/device/device_entity.dart';
import '../../../../domain/entities/analytics/analytics_entity.dart';
import '../../../blocs/auth/auth_bloc.dart';
import '../../../utils/date_time_formatter.dart';
import '../../../utils/device_display_util.dart';

class HeroSection extends StatelessWidget {
  final DeviceEntity device;
  final AnalyticsEntity? latest;
  final Color successColor;
  const HeroSection({
    super.key,
    required this.device,
    this.latest,
    this.successColor = const Color(0xFF3DDC84),
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    // ── Resolve display name: carrier if assigned, else logged-in user ──
    final authState = context.watch<AuthBloc>().state;
    final loggedInName = authState is AuthAuthenticated
        ? authState.user.fullName
        : '—';
    final displayName = ownerDisplayName(device, loggedInName);
    final isOnline = device.isOnline ?? false;

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
                backgroundImage: device.carrier?.profilePhoto != null
                    ? NetworkImage(device.carrier!.profilePhoto!)
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
                    color: colors.surface,
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
          // ── Name, Mode & Subtitle Status ─────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isOnline ? 'Live Tracking' : 'Offline',
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
                        (latest?.alert != null && latest!.alert!.isNotEmpty)
                            ? latest!.alert!
                            : 'No recent alerts',
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
                  Icon(
                    Icons.circle,
                    size: 8,
                    color: isOnline ? successColor : colors.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isOnline ? 'Online' : 'Offline',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isOnline ? successColor : colors.onSurfaceVariant,
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
              Text(
                (latest?.speed ?? 0) > 0 ? 'Travelling' : 'Stationary',
                style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant),
              ),
              const SizedBox(height: 8),
              Text(
                latest?.deviceTimestamp != null
                    ? 'Updated ${DateTimeFormatter.formatRelativeTime(latest!.deviceTimestamp)}'
                    : 'No updates yet',
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
