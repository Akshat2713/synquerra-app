import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../../app/app_router.dart';
import 'settings_tile.dart';

class SettingsScreen extends StatelessWidget {
  final String imei;
  final LatLng initialCenter;

  const SettingsScreen({
    super.key,
    required this.imei,
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
              arguments: {'imei': imei, 'center': initialCenter},
            ),
          ),
          const SizedBox(height: 16),
          // Text(
          //   'Modes Configuration',
          //   style: textTheme.labelSmall?.copyWith(
          //     color: colors.onSurfaceVariant,
          //     letterSpacing: 1.1,
          //   ),
          // ),
          // const SizedBox(height: 8),
          // SettingsTile(
          //   icon: Icons.tune_rounded,
          //   title: 'Modes',
          //   subtitle: 'Configure device tracking and power modes',
          //   onTap: () =>
          //       Navigator.pushNamed(context, AppRoutes.modes, arguments: imei),
          // ),
          // const SizedBox(height: 16),
          // Future settings panels go here
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
