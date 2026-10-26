// lib/presentation/screens/device_list/widgets/notification_panel.dart

import 'package:flutter/material.dart';
import '../../../../domain/entities/alerts/alert_entity.dart';
import '../../../../domain/entities/device/device_entity.dart';
import '../../../themes/colors.dart';
import '../../../utils/colour_util.dart';
import '../../../utils/date_time_formatter.dart';
import '../../../widgets/async_state_view.dart';
import 'package:synquerra/presentation/themes/app_tokens.dart';

import '../../../widgets/user_avatar.dart';

class NotificationPanel extends StatelessWidget {
  final List<AlertEntity> alerts;
  final List<DeviceEntity> devices;
  final String currentUserFullName;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onClose;
  final VoidCallback onMarkAllRead;
  final void Function(AlertEntity alert, DeviceEntity? device) onAlertTap;

  const NotificationPanel({
    super.key,
    required this.alerts,
    required this.devices,
    required this.currentUserFullName,
    required this.isLoading,
    required this.onClose,
    required this.onMarkAllRead,
    required this.onAlertTap,
    this.errorMessage,
  });

  /// Returns a flat list: ['Today', alert, alert, 'Yesterday', alert, ...]
  List<Object> _grouped() {
    final items = [
      for (final a in alerts)
        (a, DateTimeFormatter.parseUtcToLocal(a.createdAt)),
    ]..sort((x, y) => (y.$2 ?? DateTime(0)).compareTo(x.$2 ?? DateTime(0)));

    String section(DateTime? d) => d == null
        ? 'Earlier'
        : DateTimeFormatter.isToday(d)
        ? 'Today'
        : DateTimeFormatter.isYesterday(d)
        ? 'Yesterday'
        : 'Earlier';

    return [
      for (final label in ['Today', 'Yesterday', 'Earlier']) ...[
        if (items.any((e) => section(e.$2) == label)) label,
        for (final e in items)
          if (section(e.$2) == label) e.$1,
      ],
    ];
  }

  @override
  Widget build(BuildContext context) {
    final rows = _grouped();
    final hasUnread = alerts.any((a) => !a.isAcknowledged);

    return Material(
      elevation: 12,
      shadowColor: Colors.black.withValues(alpha: 0.25),
      borderRadius: AppRadius.lgAll,
      clipBehavior: Clip.antiAlias,
      color: AppColors.surface(context),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.7,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Header(
              showMarkAll: hasUnread,
              onMarkAll: onMarkAllRead,
              onClose: onClose,
            ),
            Divider(height: 1, color: AppColors.outlineVariant(context)),
            Flexible(
              child: AsyncStateView(
                isLoading: isLoading,
                errorMessage: errorMessage,
                isEmpty: rows.isEmpty,
                emptyMessage: 'No notifications',
                builder: () => ListView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemCount: rows.length,
                  itemBuilder: (context, i) {
                    final row = rows[i];
                    if (row is String) return _SectionHeader(label: row);

                    final alert = row as AlertEntity;
                    final device = devices
                        .where((d) => d.imei == alert.imei)
                        .firstOrNull;
                    final isLastInSection =
                        i + 1 >= rows.length || rows[i + 1] is String;

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _AlertRow(
                          alert: alert,
                          name: device?.displayOwnerName ?? alert.imei,
                          photoUrl: device?.displayProfilePhoto,
                          onTap: () {
                            onClose();
                            onAlertTap(alert, device);
                          },
                        ),
                        if (!isLastInSection)
                          Divider(
                            height: 1,
                            indent: 68,
                            color: AppColors.outlineVariant(
                              context,
                            ).withValues(alpha: 0.6),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final bool showMarkAll;
  final VoidCallback onMarkAll;
  final VoidCallback onClose;

  const _Header({
    required this.showMarkAll,
    required this.onMarkAll,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        4,
        AppSpacing.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Notifications',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary(context),
              ),
            ),
          ),
          if (showMarkAll)
            GestureDetector(
              onTap: onMarkAll,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.sm,
                ),
                child: Text(
                  'Mark all as read',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary(context),
                  ),
                ),
              ),
            ),
          IconButton(
            onPressed: onClose,
            icon: Icon(
              Icons.close_rounded,
              color: AppColors.iconSecondary(context),
            ),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.surfaceVariant(context).withValues(alpha: 0.6),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 6,
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: AppColors.textSecondary(context),
        ),
      ),
    );
  }
}

class _AlertRow extends StatelessWidget {
  final AlertEntity alert;
  final String name;
  final String? photoUrl;
  final VoidCallback onTap;

  const _AlertRow({
    required this.alert,
    required this.name,
    required this.photoUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final severityColor = alertColor(alert);
    final unread = !alert.isAcknowledged;

    return InkWell(
      onTap: onTap,
      child: Container(
        color: unread
            ? AppColors.primary(context).withValues(alpha: 0.04)
            : Colors.transparent,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 12,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UserAvatar(
              name: name,
              photoUrl: photoUrl,
              radius: 20,
              backgroundColor: AppColors.surfaceVariant(context),
              textColor: AppColors.iconSecondary(context),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            color: severityColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        DateTimeFormatter.formatFeedTime(alert.createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textTertiary(context),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    alert.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.35,
                      color: AppColors.textSecondary(context),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
