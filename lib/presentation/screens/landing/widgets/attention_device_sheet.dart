import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/entities/alerts/alert_entity.dart';
import '../../../../domain/entities/device/device_entity.dart';
import '../../../blocs/auth/auth_bloc.dart';
import '../../../blocs/device_list/device_list_bloc.dart';
import '../../../app/app_router.dart';
import '../../../utils/colour_util.dart';

class AttentionDeviceSheet extends StatelessWidget {
  final List<AlertEntity> alerts;
  const AttentionDeviceSheet({super.key, required this.alerts});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final deviceState = context.watch<DeviceListBloc>().state;
    // remove: final alertsState = context.watch<AlertsBloc>().state;
    final authState = context.watch<AuthBloc>().state;
    final currentUserFullName = authState is AuthAuthenticated
        ? authState.user.fullName
        : '—';
    final devices = deviceState is DeviceListLoaded
        ? deviceState.devices
        : <DeviceEntity>[];

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        clipBehavior:
            Clip.antiAlias, // keeps ink splashes clipped to rounded corners
        child: Material(
          color: Colors.transparent,
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Devices needing attention',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: colors.onSurface,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: devices.length,
                  itemBuilder: (context, i) {
                    final d = devices[i];
                    final deviceAlerts = alerts
                        .where((a) => a.imei == d.imei && !a.isAcknowledged)
                        .toList();
                    final ringColor = deviceSeverityColor(deviceAlerts.cast());
                    final name = d.displayOwnerName(currentUserFullName);
                    return ListTile(
                      leading: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: ringColor, width: 2),
                        ),
                        padding: const EdgeInsets.all(2),
                        child: CircleAvatar(
                          backgroundImage: d.carrier?.profilePhoto != null
                              ? CachedNetworkImageProvider(
                                  d.carrier!.profilePhoto!,
                                )
                              : null,
                          child: d.carrier?.profilePhoto == null
                              ? const Icon(Icons.person)
                              : null,
                        ),
                      ),
                      title: Text(name),
                      subtitle: Text(
                        deviceAlerts.isEmpty
                            ? 'No active alerts'
                            : '${deviceAlerts.length} unacknowledged alert${deviceAlerts.length > 1 ? 's' : ''}',
                      ),
                      onTap: () {
                        final deviceListBloc = context.read<DeviceListBloc>();
                        Navigator.pop(context);
                        Navigator.pushReplacementNamed(
                          context,
                          AppRoutes.deviceDetail,
                          arguments: DeviceDetailArgs(
                            device: d,
                            deviceListBloc: deviceListBloc,
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
