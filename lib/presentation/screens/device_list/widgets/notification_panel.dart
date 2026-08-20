// lib/presentation/screens/device_list/widgets/notification_panel.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../domain/entities/alerts/alert_entity.dart';
import '../../../../domain/entities/device/device_entity.dart';
import '../../../utils/colour_util.dart';
import '../../../widgets/async_state_view.dart';

class NotificationPanel extends StatelessWidget {
  final List<AlertEntity> alerts;
  final List<DeviceEntity> devices;
  final String currentUserFullName;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onClose;
  final void Function(AlertEntity alert, DeviceEntity? device) onAlertTap;

  const NotificationPanel({
    super.key,
    required this.alerts,
    required this.devices,
    required this.currentUserFullName,
    required this.isLoading,
    required this.onClose,
    required this.onAlertTap,
    this.errorMessage,
  });

  int _severityRank(AlertSeverity s) => switch (s) {
    AlertSeverity.critical => 0,
    AlertSeverity.warning => 1,
    AlertSeverity.advisory => 2,
  };

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final sortedAlerts = [...alerts]
      ..sort((a, b) {
        final r = _severityRank(
          a.severity,
        ).compareTo(_severityRank(b.severity));
        if (r != 0) return r;
        return b.createdAt.compareTo(a.createdAt);
      });

    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      color: colors.surface,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 420),
        child: AsyncStateView(
          isLoading: isLoading,
          errorMessage: errorMessage,
          isEmpty: sortedAlerts.isEmpty,
          emptyMessage: 'No alerts',
          builder: () => ListView.separated(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(vertical: 4),
            itemCount: sortedAlerts.length,
            separatorBuilder: (_, __) =>
                Divider(height: 1, color: colors.outlineVariant),
            itemBuilder: (context, i) {
              final alert = sortedAlerts[i];
              final device = devices
                  .where((d) => d.imei == alert.imei)
                  .firstOrNull;
              final name =
                  device?.displayOwnerName(currentUserFullName) ?? alert.imei;

              return ListTile(
                dense: true,
                leading: CircleAvatar(
                  backgroundImage: device?.carrier?.profilePhoto != null
                      ? CachedNetworkImageProvider(
                          device!.carrier!.profilePhoto!,
                        )
                      : null,
                  child: device?.carrier?.profilePhoto == null
                      ? const Icon(Icons.person)
                      : null,
                ),
                title: Text(name),
                subtitle: Text(
                  alert.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Icon(
                  alert.severity == AlertSeverity.critical
                      ? Icons.error_rounded
                      : Icons.warning_amber_rounded,
                  color: alertColor(alert),
                  size: 20,
                ),
                onTap: () {
                  onClose();
                  onAlertTap(alert, device);
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
