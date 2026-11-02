import 'package:flutter/material.dart';
import '../../../themes/app_text_styles.dart';
import '../../../themes/app_tokens.dart';
import '../../../themes/colors.dart';
import '../../../utils/colour_util.dart';
import '../../../utils/unit_formatter.dart';

import '../../../widgets/app_surfaces.dart';

class BottomMetricsBar extends StatelessWidget {
  final int battery;
  final String networkStatus;
  final String temperature;

  const BottomMetricsBar({
    super.key,
    required this.battery,
    this.networkStatus = 'Fair',
    required this.temperature,
  });

  // TODO(logic): make DeviceEntity.temperature a num? and drop this parsing.
  String get _temperatureLabel {
    final t = num.tryParse(temperature);
    return t == null ? temperature : UnitFormatter.formatTemperature(t);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.smd,
        horizontal: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        border: Border(
          top: BorderSide(
            color: AppAlpha.withBorderAlpha(AppColors.outlineVariant(context)),
          ),
        ),
      ),
      child: Row(
        children: [
          _MetricCell(
            title: 'NETWORK\nSTRENGTH',
            icon: Icons.signal_cellular_alt,
            value: networkStatus,
            color: AppColors.warning,
          ),
          // TODO(logic): static for now.
          const _MetricCell(
            title: 'LOCATION\nCONFIDENCE',
            icon: Icons.wifi,
            value: 'Poor',
            color: AppColors.warning,
          ),
          _MetricCell(
            title: 'CURRENT\nBATTERY',
            icon: Icons.battery_4_bar_rounded,
            value: '$battery%',
            color: batteryColor(battery),
          ),
          _MetricCell(
            title: 'DEVICE\nTEMP',
            icon: Icons.thermostat,
            value: _temperatureLabel,
            color: temperatureColor(temperature),
          ),
        ],
      ),
    );
  }
}

class _MetricCell extends StatelessWidget {
  final String title;
  final IconData icon;
  final String value;
  final Color color;

  const _MetricCell({
    required this.title,
    required this.icon,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconTile(
          circle: true,
          size: AppSize.avatarSm,
          iconSize: AppSize.iconSm,
          icon: icon,
          background: AppAlpha.withAlpha(color, AppAlpha.fill),
          foreground: color,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: AppTextStyles.metaWithColor(
            context,
            color: color,
          ).copyWith(fontWeight: FontWeight.w700),
        ),
        Text(
          title,
          textAlign: TextAlign.center,
          style: AppTextStyles.microWithColor(context),
        ),
      ],
    ),
  );
}
