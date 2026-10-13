// presentation/utils/device_event_router.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:synquerra/core/utils/app_logger.dart';

import '../../core/services/sos_alarm_service.dart';
import '../../domain/entities/realtime/device_alert.dart';
import '../../domain/entities/realtime/device_event.dart';
import '../blocs/sos/sos_bloc.dart';
import '../screens/sos/sos_screen.dart';
import '../widgets/device_event_banner.dart';
import '../../core/di/injection_container.dart';

enum AlertSurface { banner, fullScreen, silent }

class AlertRule {
  const AlertRule.banner() : surface = AlertSurface.banner, builder = null;
  const AlertRule.silent() : surface = AlertSurface.silent, builder = null;
  const AlertRule.fullScreen(this.builder) : surface = AlertSurface.fullScreen;

  final AlertSurface surface;
  final Widget Function(DeviceAlert alert, String deviceName)? builder;
}

/// One line per alert code needing special handling.
/// Anything not listed -> normal top banner.
final Map<String, AlertRule> alertRules = {
  AlertCodes.sos: AlertRule.fullScreen(
    (alert, deviceName) => BlocProvider<SosBloc>.value(
      value: sl<SosBloc>(),
      child: SosScreen(alert: alert, deviceName: deviceName),
    ),
  ),
};

bool _fullScreenOpen = false;

void handleDeviceEvent(
  BuildContext context,
  DeviceEvent event,
  String deviceName,
) {
  AppLogger.d('Device Event Router', 'The owner name is $deviceName');
  switch (event) {
    case ModeChanged():
      showDeviceEventBanner(context, event, deviceName: deviceName);
    case AlertReceived(:final alert):
      final rule = alertRules[alert.code] ?? const AlertRule.banner();
      switch (rule.surface) {
        case AlertSurface.silent:
          return;
        case AlertSurface.banner:
          showDeviceEventBanner(context, event, deviceName: deviceName);
        case AlertSurface.fullScreen:
          if (_fullScreenOpen) return;
          _fullScreenOpen = true;

          if (alert.code == AlertCodes.sos) {
            sl<SosAlarmService>().start();
          }
          AppLogger.d(
            'Device Event Router in case',
            'The owner name is $deviceName',
          );

          Navigator.of(context, rootNavigator: true)
              .push(
                PageRouteBuilder<void>(
                  opaque: true,
                  fullscreenDialog: true,
                  pageBuilder: (_, __, ___) => rule.builder!(alert, deviceName),
                  transitionsBuilder: (_, a, __, child) =>
                      FadeTransition(opacity: a, child: child),
                ),
              )
              .whenComplete(() {
                _fullScreenOpen = false;
                sl<SosAlarmService>().stop(); // safety net
              });
      }
  }
}
