import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/entities/alerts/alert_entity.dart';
import '../../../../domain/entities/device/device_entity.dart';
import '../../../blocs/auth/auth_bloc.dart';
import '../../../utils/colour_util.dart';
import '../../../utils/device_alert_matcher.dart';
import '../../../utils/device_display_util.dart';

class AttentionBanner extends StatelessWidget {
  final List<DeviceEntity> devices;
  final List<AlertEntity> alerts;
  final VoidCallback onTap;
  const AttentionBanner({
    super.key,
    required this.devices,
    required this.alerts,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final attentionCount = devices.where((d) {
      final deviceAlerts = alertsForDevice(d, alerts);
      return deviceAlerts.any((a) => a.isCritical && !a.isAcknowledged);
    }).length;

    return Material(
      color: colors.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: colors.outline, width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$attentionCount needs attention',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      '${devices.length} devices',
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              _AvatarStack(devices: devices, alerts: alerts),
              const SizedBox(width: 6),
              Icon(
                Icons.chevron_right_rounded,
                color: colors.onSurfaceVariant,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AvatarStack extends StatelessWidget {
  final List<DeviceEntity> devices;
  final List<AlertEntity> alerts;
  const _AvatarStack({required this.devices, required this.alerts});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final authState = context.watch<AuthBloc>().state;
    final currentUserFullName = authState is AuthAuthenticated
        ? authState.user.fullName
        : '—';

    const size = 28.0;
    const overlap = 10.0;
    final shown = devices.take(3).toList();
    final extra = devices.length - shown.length;

    return SizedBox(
      width:
          size + (shown.length - 1) * (size - overlap) + (extra > 0 ? 20 : 0),
      height: size,
      child: Stack(
        children: [
          ...shown.asMap().entries.map((e) {
            final d = e.value;
            final deviceAlerts = alertsForDevice(
              d,
              alerts,
            ).where((a) => !a.isAcknowledged).toList();
            final ringColor = deviceSeverityColor(deviceAlerts);
            final name = ownerDisplayName(d, currentUserFullName).trim();
            final parts = name
                .split(RegExp(r'\s+'))
                .where((p) => p.isNotEmpty)
                .toList();
            final initials = parts.length >= 2
                ? '${parts[0][0]}${parts[1][0]}'
                : (parts.isNotEmpty ? parts[0][0] : '?');

            return Positioned(
              left: e.key * (size - overlap),
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: ringColor, width: 2),
                ),
                padding: const EdgeInsets.all(1.5),
                child: CircleAvatar(
                  backgroundColor: colors.primaryContainer,
                  backgroundImage: d.carrier?.profilePhoto != null
                      ? NetworkImage(d.carrier!.profilePhoto!)
                      : null,
                  child: d.carrier?.profilePhoto == null
                      ? Text(
                          initials,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: colors.onPrimaryContainer,
                          ),
                        )
                      : null,
                ),
              ),
            );
          }),
          if (extra > 0)
            Positioned(
              left: shown.length * (size - overlap),
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: colors.surface, width: 1.5),
                  color: colors.surfaceContainerHighest,
                ),
                alignment: Alignment.center,
                child: Text(
                  '+$extra',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
