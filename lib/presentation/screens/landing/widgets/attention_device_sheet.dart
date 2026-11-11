import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../themes/app_text_styles.dart';
import '../../../themes/app_tokens.dart';
import '../../../themes/colors.dart';
import '../../../utils/app_icons.dart';
import '../../../utils/colour_util.dart';
import '../../../widgets/app_empty_state.dart';
import '../../../widgets/app_surfaces.dart';
import '../../../widgets/user_avatar.dart';
import '../../../../domain/entities/alerts/alert_entity.dart';
import '../../../../domain/entities/device/device_entity.dart';
import '../../../../domain/utils/alert_device_matcher.dart';
import '../../../app/app_router.dart';
import '../../../blocs/device_list/device_list_bloc.dart';

class AttentionDeviceSheet extends StatelessWidget {
  final List<AlertEntity> alerts;
  final String? currentDeviceId;
  const AttentionDeviceSheet({
    super.key,
    required this.alerts,
    this.currentDeviceId,
  });

  @override
  Widget build(BuildContext context) {
    final deviceState = context.watch<DeviceListBloc>().state;
    final devices = deviceState is DeviceListLoaded
        ? deviceState.devices
        : <DeviceEntity>[];

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        0,
        AppSpacing.md,
        AppSpacing.md,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpacing.md,
        children: [
          Text(
            'Devices needing attention',
            style: AppTextStyles.titleWithColor(context),
          ),
          if (devices.isEmpty)
            const AppEmptyState(icon: AppIcons.devices, title: 'No devices')
          else
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: devices.length,
                itemBuilder: (context, i) => _DeviceRow(
                  device: devices[i],
                  alerts: alerts,
                  isCurrent: devices[i].id == currentDeviceId,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DeviceRow extends StatelessWidget {
  final DeviceEntity device;
  final List<AlertEntity> alerts;
  final bool isCurrent;

  const _DeviceRow({
    required this.device,
    required this.alerts,
    required this.isCurrent,
  });

  @override
  Widget build(BuildContext context) {
    final open = alertsForDevice(
      device,
      alerts,
    ).where((a) => !a.isAcknowledged).toList();
    final critical = open.where((a) => a.isCritical).length;

    // InsetRow carries its own bottom padding, so no separators or spacing.
    return InsetRow(
      onTap: () {
        final bloc = context.read<DeviceListBloc>();
        Navigator.pop(context);
        AppRouter.pushDeviceDetail(
          context,
          device: device,
          deviceListBloc: bloc,
        );
      },
      child: Row(
        spacing: AppSpacing.smd,
        children: [
          Container(
            padding: AppSpacing.xsAll,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: deviceSeverityColor(open),
                width: AppSize.stroke,
              ),
            ),
            child: UserAvatar(
              name: device.displayOwnerName,
              photoUrl: device.displayProfilePhoto,
              radius: AppSize.tile / 2,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: AppSpacing.xs,
              children: [
                Text(
                  device.displayOwnerName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.sectionWithColor(context).copyWith(
                    fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w600,
                  ),
                ),
                if (critical == 0)
                  Text(
                    'No critical alerts',
                    style: AppTextStyles.metaWithColor(context),
                  )
                else
                  InfoPill(
                    label: '$critical critical alert${critical > 1 ? 's' : ''}',
                    dotColor: AppColors.danger,
                    background: AppColors.dangerContainer,
                    foreground: AppColors.textPrimary(context),
                  ),
              ],
            ),
          ),
          Icon(
            AppIcons.chevron,
            size: AppSize.icon,
            color: AppColors.primary(context),
          ),
        ],
      ),
    );
  }
}
