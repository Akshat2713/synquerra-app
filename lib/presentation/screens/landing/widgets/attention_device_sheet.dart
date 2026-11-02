import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../themes/app_text_styles.dart';
import '../../../themes/app_tokens.dart';
import '../../../utils/colour_util.dart';
import '../../../widgets/user_avatar.dart';
import '../../../../domain/entities/alerts/alert_entity.dart';
import '../../../../domain/entities/device/device_entity.dart';
import '../../../../domain/utils/alert_device_matcher.dart';
import '../../../app/app_router.dart';
import '../../../blocs/device_list/device_list_bloc.dart';
import '../../../themes/colors.dart';

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

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) => Column(
        children: [
          Padding(
            padding: AppSpacing.mdAll,
            child: Text(
              'Devices needing attention',
              style: AppTextStyles.sectionWithColor(context),
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              itemCount: devices.length,
              itemBuilder: (context, i) {
                final d = devices[i];
                final open = alertsForDevice(
                  d,
                  alerts,
                ).where((a) => !a.isAcknowledged).toList();
                final critical = open.where((a) => a.isCritical).length;
                final isCurrent = d.id == currentDeviceId;

                return ListTile(
                  leading: Container(
                    padding: AppSpacing.xsAll,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: deviceSeverityColor(open),
                        width: AppSize.stroke,
                      ),
                    ),
                    child: UserAvatar(
                      name: d.displayOwnerName,
                      photoUrl: d.displayProfilePhoto,
                      radius: AppSize.tile / 2,
                    ),
                  ),
                  title: Text(
                    d.displayOwnerName,
                    style:
                        AppTextStyles.bodyWithColor(
                          context,
                          color: AppColors.textPrimary(context),
                        ).copyWith(
                          fontWeight: isCurrent
                              ? FontWeight.w800
                              : FontWeight.w500,
                        ),
                  ),
                  subtitle: Text(
                    critical == 0
                        ? 'No critical alerts'
                        : '$critical critical alert${critical > 1 ? 's' : ''}',
                    style: AppTextStyles.metaWithColor(context),
                  ),
                  onTap: () {
                    final bloc = context.read<DeviceListBloc>();
                    Navigator.pop(context);
                    AppRouter.pushDeviceDetail(
                      context,
                      device: d,
                      deviceListBloc: bloc,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
