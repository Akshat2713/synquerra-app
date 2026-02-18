import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:synquerra/core/preferences/interval_preferences.dart';
import 'package:synquerra/core/services/update_device_service.dart';
import 'package:synquerra/providers/intervals_provider.dart';
import 'package:synquerra/providers/user_provider.dart';
import 'package:synquerra/screens/landing/home/profile_drawer/settings/geofence_screen.dart';
import 'package:synquerra/widgets/edit_value_dialog.dart';
import 'package:synquerra/theme/colors.dart';

class DeviceSettingsScreen extends StatefulWidget {
  const DeviceSettingsScreen({super.key});

  @override
  State<DeviceSettingsScreen> createState() => _DeviceSettingsScreenState();
}

class _DeviceSettingsScreenState extends State<DeviceSettingsScreen> {
  String? _selectedDevice = 'Rahul Kumar (f5v11vfx)';
  final List<String> _devices = [
    'Rahul Kumar (f5v11vfx)',
    'Anjali Sharma (g8h22wgy)',
    'Office Tracker (z1k99abc)',
    'Dad\'s Car (h4j55xyz)',
    'Mom\'s Phone (p9q88lmn)',
  ];

  // Hardware switches
  bool _ambientListening = true;
  bool _ledIndicator = true;
  bool _aeroplaneMode = false;
  bool _privacyMode = false;
  bool _incognitoMode = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<IntervalsProvider>().loadSettingsFromDisk();
    });
  }

  Future<void> _updateIntervalSetting(String key, String value) async {
    final intervalsProv = context.read<IntervalsProvider>();
    final updateService = context.read<UpdateDeviceService>();
    final userProv = context.read<UserProvider>();
    final imei = userProv.user?.imei;

    if (imei == null) return;

    try {
      await intervalsProv.setSetting(key, value);
      final response = await updateService.updateDeviceSettings(
        imei: imei,
        settings: {key: value},
      );

      if (response.status == 'SENT' && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Device updated: ${response.note}")),
        );
      }
    } catch (e) {
      debugPrint("Update failed for $key: $e");
    }
  }

  void _showEditDialog({
    required BuildContext context,
    required String title,
    required String currentValue,
    required Function(String) onSave,
    TextInputType keyboardType = TextInputType.text,
    String? valueSuffix,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return EditValueDialog(
          title: title,
          initialValue: currentValue,
          onSave: onSave,
          keyboardType: keyboardType,
          valueSuffix: valueSuffix,
        );
      },
    );
  }

  // Styles
  final TextStyle _underlinedTextStyle = const TextStyle(
    decoration: TextDecoration.underline,
    decorationColor: Colors.grey,
    decorationThickness: 1,
    fontSize: 17,
    fontWeight: FontWeight.w500,
  );

  final TextStyle _clickableTextStyle = const TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w500,
  );

  final TextStyle _valueTextStyle = const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.blueAccent,
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final settings = context.watch<IntervalsProvider>().localSettings;

    // Helper to fetch data safely
    String val(String key, String def) => settings[key] ?? def;

    return Scaffold(
      appBar: AppBar(title: const Text("Device Settings")),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // --- Choose Device Section ---
          _buildDeviceSelector(theme, colorScheme),

          // --- Alerts and Safety Section ---
          _buildSectionCard(
            context: context,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(Icons.shield_outlined, "Alerts and Safety", theme),
                const SizedBox(height: 15),
                _buildNavigationRow(
                  context: context,
                  title: "Geofences",
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const GeofenceScreen()),
                  ),
                ),
                _buildValueRow(
                  context: context,
                  title: "Speed Limit",
                  value: "${val(IntervalPreferences.keySpeedLimit, "70")}",
                  onTap: () => _showEditDialog(
                    context: context,
                    title: "Set Speed Limit",
                    currentValue: val(IntervalPreferences.keySpeedLimit, "70"),
                    keyboardType: TextInputType.number,
                    valueSuffix: " KM/hr",
                    onSave: (v) => _updateIntervalSetting(
                      IntervalPreferences.keySpeedLimit,
                      v,
                    ),
                  ),
                ),
                _buildValueRow(
                  context: context,
                  title: "Temperature Limit",
                  value: "${val(IntervalPreferences.keyTempLimit, "32")}",
                  onTap: () => _showEditDialog(
                    context: context,
                    title: "Set Temperature Limit",
                    currentValue: val(IntervalPreferences.keyTempLimit, "32"),
                    keyboardType: TextInputType.number,
                    valueSuffix: "°C",
                    onSave: (v) => _updateIntervalSetting(
                      IntervalPreferences.keyTempLimit,
                      v,
                    ),
                  ),
                ),
                _buildValueRow(
                  context: context,
                  title: "Low Battery Limit",
                  value: "${val(IntervalPreferences.keyLowBatLimit, "20")}",
                  onTap: () => _showEditDialog(
                    context: context,
                    title: "Set Low Battery Limit",
                    currentValue: val(IntervalPreferences.keyLowBatLimit, "20"),
                    keyboardType: TextInputType.number,
                    valueSuffix: "%",
                    onSave: (v) => _updateIntervalSetting(
                      IntervalPreferences.keyLowBatLimit,
                      v,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // --- Intervals Section ---
          _buildSectionCard(
            context: context,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(Icons.timer_outlined, "Intervals", theme),
                const SizedBox(height: 15),
                _buildValueRow(
                  context: context,
                  title: "Normal Sending Interval",
                  value: "${val(IntervalPreferences.keyNormalSending, "300")}",
                  onTap: () => _showEditDialog(
                    context: context,
                    title: "Normal Sending Interval",
                    currentValue: val(
                      IntervalPreferences.keyNormalSending,
                      "300",
                    ),
                    keyboardType: TextInputType.number,
                    valueSuffix: "s",
                    onSave: (v) => _updateIntervalSetting(
                      IntervalPreferences.keyNormalSending,
                      v,
                    ),
                  ),
                ),
                _buildValueRow(
                  context: context,
                  title: "SOS Sending Interval",
                  value: "${val(IntervalPreferences.keySOSSending, "60")}",
                  onTap: () => _showEditDialog(
                    context: context,
                    title: "SOS Sending Interval",
                    currentValue: val(IntervalPreferences.keySOSSending, "60"),
                    keyboardType: TextInputType.number,
                    valueSuffix: "s",
                    onSave: (v) => _updateIntervalSetting(
                      IntervalPreferences.keySOSSending,
                      v,
                    ),
                  ),
                ),
                _buildValueRow(
                  context: context,
                  title: "Normal GPS Scan Interval",
                  value: "${val(IntervalPreferences.keyNormalScanning, "200")}",
                  onTap: () => _showEditDialog(
                    context: context,
                    title: "Normal Scanning Interval",
                    currentValue: val(
                      IntervalPreferences.keyNormalScanning,
                      "200",
                    ),
                    keyboardType: TextInputType.number,
                    valueSuffix: "s",
                    onSave: (v) => _updateIntervalSetting(
                      IntervalPreferences.keyNormalScanning,
                      v,
                    ),
                  ),
                ),
                _buildValueRow(
                  context: context,
                  title: "Aeroplane Scan Interval",
                  value: "${val(IntervalPreferences.keyAirplane, "300")}",
                  onTap: () => _showEditDialog(
                    context: context,
                    title: "Aeroplane Scan Interval",
                    currentValue: val(IntervalPreferences.keyAirplane, "300"),
                    keyboardType: TextInputType.number,
                    valueSuffix: "s",
                    onSave: (v) => _updateIntervalSetting(
                      IntervalPreferences.keyAirplane,
                      v,
                    ),
                  ),
                ),
                // RESTORED: Low Battery Data Interval
                _buildValueRow(
                  context: context,
                  title: "Low battery Data Sending Interval",
                  value: "${val(IntervalPreferences.keyLowBatData, "900")}",
                  onTap: () => _showEditDialog(
                    context: context,
                    title: "Low Battery Data Interval",
                    currentValue: val(IntervalPreferences.keyLowBatData, "900"),
                    keyboardType: TextInputType.number,
                    valueSuffix: "s",
                    onSave: (v) => _updateIntervalSetting(
                      IntervalPreferences.keyLowBatData,
                      v,
                    ),
                  ),
                ),
                // RESTORED: Low Battery GPS Interval
                _buildValueRow(
                  context: context,
                  title: "Low battery GPS Sending Interval",
                  value: "${val(IntervalPreferences.keyLowBatGps, "600")}",
                  onTap: () => _showEditDialog(
                    context: context,
                    title: "Low Battery GPS Interval",
                    currentValue: val(IntervalPreferences.keyLowBatGps, "600"),
                    keyboardType: TextInputType.number,
                    valueSuffix: "s",
                    onSave: (v) => _updateIntervalSetting(
                      IntervalPreferences.keyLowBatGps,
                      v,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // --- Hardware Controls Section ---
          _buildSectionCard(
            context: context,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(
                  Icons.settings_remote_outlined,
                  "Hardware Controls",
                  theme,
                ),
                const SizedBox(height: 5),
                _buildSwitchRow(
                  context,
                  "Ambient Listening",
                  _ambientListening,
                  (v) => setState(() => _ambientListening = v),
                ),
                _buildSwitchRow(
                  context,
                  "LED Indicator",
                  _ledIndicator,
                  (v) => setState(() => _ledIndicator = v),
                ),
                _buildSwitchRow(
                  context,
                  "Aeroplane Mode",
                  _aeroplaneMode,
                  (v) => setState(() => _aeroplaneMode = v),
                ),
                _buildSwitchRow(
                  context,
                  "Privacy Mode",
                  _privacyMode,
                  (v) => setState(() => _privacyMode = v),
                ),
                _buildSwitchRow(
                  context,
                  "Incognito Mode",
                  _incognitoMode,
                  (v) => setState(() => _incognitoMode = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          _buildVersionCard(
            context,
            Icons.memory_outlined,
            "Firmware version",
            "1.4.2-Build-301",
          ),
          const SizedBox(height: 20),
          _buildVersionCard(
            context,
            Icons.developer_mode_outlined,
            "Software version",
            "3.06.19",
          ),
        ],
      ),
    );
  }

  // UI Helpers (Simplified for clarity)
  Widget _buildHeader(IconData icon, String title, ThemeData theme) {
    return Row(
      children: [
        Icon(icon, color: theme.colorScheme.primary, size: 28),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildDeviceSelector(ThemeData theme, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(Icons.person_outline, "Choose a device", theme),
          const Padding(
            padding: EdgeInsets.only(left: 36.0),
            child: Text("to view setting of that device"),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedDevice,
                isExpanded: true,
                onChanged: (v) => setState(() => _selectedDevice = v),
                items: _devices
                    .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required BuildContext context,
    required Widget child,
  }) {
    return Card(
      elevation: 4,
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
        child: child,
      ),
    );
  }

  Widget _buildValueRow({
    required BuildContext context,
    required String title,
    required String value,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: _clickableTextStyle.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            Text(value, style: _valueTextStyle),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationRow({
    required BuildContext context,
    required String title,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: _underlinedTextStyle.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Theme.of(
                context,
              ).colorScheme.onSurfaceVariant.withOpacity(0.7),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchRow(
    BuildContext context,
    String title,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: _clickableTextStyle.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: AppColors.safeGreen,
        ),
      ],
    );
  }

  Widget _buildVersionCard(
    BuildContext context,
    IconData icon,
    String title,
    String version,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return _buildSectionCard(
      context: context,
      child: Row(
        children: [
          Icon(icon, color: colorScheme.primary, size: 28),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                version,
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
