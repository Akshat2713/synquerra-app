import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../../app/app_router.dart';
import 'settings_tile.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/device/device_entity.dart';
import '../../blocs/analytics/analytics_bloc.dart';

class SettingsScreen extends StatelessWidget {
  final DeviceEntity device;
  final LatLng initialCenter;
  const SettingsScreen({
    super.key,
    required this.device,
    required this.initialCenter,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Account',
            style: textTheme.labelSmall?.copyWith(
              color: colors.onSurfaceVariant,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          Builder(
            builder: (ctx) => SettingsTile(
              icon: Icons.person_outline_rounded,
              title: 'Manage',
              subtitle: 'View device owner & mode details',
              onTap: () {
                final analyticsBloc = ctx.read<AnalyticsBloc>();
                final analyticsState = analyticsBloc.state;
                final latest =
                    analyticsState is AnalyticsLoaded &&
                        analyticsState.points.isNotEmpty
                    ? analyticsState.points.first
                    : null;
                Navigator.pushNamed(
                  ctx,
                  AppRoutes.profile,
                  arguments: {
                    'device': device,
                    'analytics': latest,
                    'analyticsBloc': analyticsBloc,
                  },
                );
              },
            ),
          ),
          // const SizedBox(height: 8),
          // SettingsTile(
          //   icon: Icons.analytics_outlined,
          //   title: 'Telemetry History',
          //   subtitle: 'View full location & sensor history',
          //   onTap: () => Navigator.pushNamed(
          //     context,
          //     AppRoutes.telemetryHistory,
          //     arguments: device,
          //   ),
          // ),
          const SizedBox(height: 16),

          Text(
            'Zone Management',
            style: textTheme.labelSmall?.copyWith(
              color: colors.onSurfaceVariant,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          SettingsTile(
            icon: Icons.fence_rounded,
            title: 'Geofences',
            subtitle: 'Create and manage geofence zones',
            onTap: () => Navigator.pushNamed(
              context,
              AppRoutes.geofence,
              // NEW
              arguments: {'deviceId': device.id, 'center': initialCenter},
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Coming Soon',
            style: textTheme.labelSmall?.copyWith(
              color: colors.onSurfaceVariant,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          SettingsTile(
            icon: Icons.fence_rounded,
            title: 'Other features',
            subtitle:
                'These features are in development and will be available in future updates.',
            onTap: () => {},
          ),
        ],
      ),
    );
  }
}
