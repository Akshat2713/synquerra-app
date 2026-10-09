import 'package:flutter/material.dart';

import '../../domain/entities/realtime/device_alert.dart';
import '../../domain/entities/realtime/device_event.dart';
import '../widgets/device_event_banner.dart';

enum AlertSurface { banner, fullScreen, silent }

class AlertRule {
  const AlertRule.banner() : surface = AlertSurface.banner, builder = null;
  const AlertRule.silent() : surface = AlertSurface.silent, builder = null;
  const AlertRule.fullScreen(this.builder) : surface = AlertSurface.fullScreen;

  final AlertSurface surface;
  final Widget Function(DeviceAlert alert)? builder;
}

/// One line per alert code needing special handling.
/// Anything not listed -> normal top banner.
final Map<String, AlertRule> alertRules = {
  // AlertCodes.sos: AlertRule.fullScreen((a) => SosAlertScreen(alert: a)),
  // AlertCodes.charging: const AlertRule.banner(),
};

bool _fullScreenOpen = false;

void handleDeviceEvent(
  BuildContext context,
  DeviceEvent event, {
  String? deviceName,
}) {
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
          Navigator.of(context, rootNavigator: true)
              .push(
                PageRouteBuilder<void>(
                  opaque: true,
                  fullscreenDialog: true,
                  pageBuilder: (_, __, ___) => rule.builder!(alert),
                  transitionsBuilder: (_, a, __, child) =>
                      FadeTransition(opacity: a, child: child),
                ),
              )
              .whenComplete(() => _fullScreenOpen = false);
      }
  }
}
