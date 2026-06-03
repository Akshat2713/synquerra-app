/// AlertCodeHelper — pure static utility.
/// Maps device alert/error codes to human-readable metadata.
/// No UI dependency. Use this anywhere in the app to resolve a code.
///
/// Usage:
///   AlertCodeHelper.labelFor('A1002')   → 'SOS'
///   AlertCodeHelper.iconFor('E1001')    → Icons.satellite_alt_rounded
///   AlertCodeHelper.colorFor('A1003', colors) → colors.error
library;

import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Public API
// ─────────────────────────────────────────────────────────────────────────────

class AlertCodeHelper {
  AlertCodeHelper._();

  /// Resolves a raw code string from the device (e.g. 'A1002') to metadata.
  static AlertMeta resolve(String? code) {
    if (code == null || code.trim().isEmpty) return _unknown(code);
    return _codes[code.trim().toUpperCase()] ?? _unknown(code);
  }

  /// Human-readable label for the given code.
  static String labelFor(String? code) => resolve(code).label;

  /// Icon representing the alert type.
  static IconData iconFor(String? code) => resolve(code).icon;

  /// Severity-based colour using the current [ColorScheme].
  static Color colorFor(String? code, ColorScheme colors) =>
      _severityColor(resolve(code).severity, colors);

  // ── Internal ──────────────────────────────────────────────────────────────

  static AlertMeta _unknown(String? code) => AlertMeta(
    code: code ?? '—',
    label: code != null && code.isNotEmpty ? code : 'Unknown',
    description: 'Unrecognised alert code.',
    icon: Icons.help_outline_rounded,
    severity: AlertSeverity.info,
    category: AlertCategory.other,
  );

  static Color _severityColor(AlertSeverity s, ColorScheme colors) {
    switch (s) {
      case AlertSeverity.critical:
        return colors.error;
      case AlertSeverity.warning:
        return Colors.orange;
      case AlertSeverity.info:
        return colors.primary;
    }
  }

  // ── Code table ────────────────────────────────────────────────────────────
  // Source: device firmware documentation
  // A-codes → Alert packets   (packet = 'A')
  // E-codes → Error packets   (packet = 'A', but error category)

  static const Map<String, AlertMeta> _codes = {
    // ── Alert codes (A-series) ────────────────────────────────────────────
    'A1001': AlertMeta(
      code: 'A1001',
      label: 'Charging',
      description: 'Device is currently charging.',
      icon: Icons.battery_charging_full_rounded,
      severity: AlertSeverity.info,
      category: AlertCategory.power,
    ),
    'A1002': AlertMeta(
      code: 'A1002',
      label: 'SOS',
      description: 'SOS button was held for 5 seconds.',
      icon: Icons.emergency_rounded,
      severity: AlertSeverity.critical,
      category: AlertCategory.sos,
    ),
    'A1003': AlertMeta(
      code: 'A1003',
      label: 'Tampered',
      description: 'Device has been tampered with.',
      icon: Icons.report_problem_rounded,
      severity: AlertSeverity.critical,
      category: AlertCategory.tamper,
    ),
    'A1004': AlertMeta(
      code: 'A1004',
      label: 'GPS Disabled',
      description: 'GPS on the device has been disabled.',
      icon: Icons.location_off_rounded,
      severity: AlertSeverity.warning,
      category: AlertCategory.gps,
    ),
    'A1005': AlertMeta(
      code: 'A1005',
      label: 'Charger Removed',
      description: 'Charger has been removed from the device.',
      icon: Icons.power_off_rounded,
      severity: AlertSeverity.warning,
      category: AlertCategory.power,
    ),

    // ── Error codes (E-series) ────────────────────────────────────────────
    'E1001': AlertMeta(
      code: 'E1001',
      label: 'GNSS Connectivity Error',
      description: 'Issue in GNSS UART receiving or invalid packet received.',
      icon: Icons.satellite_alt_rounded,
      severity: AlertSeverity.warning,
      category: AlertCategory.gps,
    ),
    'E1002': AlertMeta(
      code: 'E1002',
      label: 'Network Registration Failed',
      description: 'Device failed to register on the network.',
      icon: Icons.signal_cellular_off_rounded,
      severity: AlertSeverity.warning,
      category: AlertCategory.network,
    ),
    'E1003': AlertMeta(
      code: 'E1003',
      label: 'No Data Capability',
      description: 'Device failed to establish a data connection.',
      icon: Icons.mobiledata_off_rounded,
      severity: AlertSeverity.warning,
      category: AlertCategory.network,
    ),
    'E1004': AlertMeta(
      code: 'E1004',
      label: 'Poor Network Strength',
      description: 'Device is operating under poor network signal strength.',
      icon: Icons.network_check_rounded,
      severity: AlertSeverity.warning,
      category: AlertCategory.network,
    ),
    'E1005': AlertMeta(
      code: 'E1005',
      label: 'MQTT Connection Failed',
      description: 'Device failed to initialise MQTT connection.',
      icon: Icons.cloud_off_rounded,
      severity: AlertSeverity.warning,
      category: AlertCategory.connectivity,
    ),
    'E1006': AlertMeta(
      code: 'E1006',
      label: 'FTP Connection Failed',
      description: 'Device failed to initialise FTP connection.',
      icon: Icons.folder_off_rounded,
      severity: AlertSeverity.warning,
      category: AlertCategory.connectivity,
    ),
    'E1011': AlertMeta(
      code: 'E1011',
      label: 'No SIM',
      description: 'No SIM card detected in the device.',
      icon: Icons.sim_card_alert_rounded,
      severity: AlertSeverity.critical,
      category: AlertCategory.network,
    ),
    'E1012': AlertMeta(
      code: 'E1012',
      label: 'Microphone Error',
      description: 'Issue detected in microphone connection.',
      icon: Icons.mic_off_rounded,
      severity: AlertSeverity.info,
      category: AlertCategory.hardware,
    ),
    'E1013': AlertMeta(
      code: 'E1013',
      label: 'Flash Memory Malfunction',
      description: 'Issue detected in flash memory.',
      icon: Icons.memory_rounded,
      severity: AlertSeverity.warning,
      category: AlertCategory.hardware,
    ),
  };
}

// ─────────────────────────────────────────────────────────────────────────────
// Data models (kept in same file for locality — no UI imports needed)
// ─────────────────────────────────────────────────────────────────────────────

enum AlertSeverity { critical, warning, info }

enum AlertCategory {
  sos,
  power,
  tamper,
  gps,
  network,
  connectivity,
  hardware,
  other,
}

class AlertMeta {
  final String code;
  final String label;
  final String description;
  final IconData icon;
  final AlertSeverity severity;
  final AlertCategory category;

  const AlertMeta({
    required this.code,
    required this.label,
    required this.description,
    required this.icon,
    required this.severity,
    required this.category,
  });
}
