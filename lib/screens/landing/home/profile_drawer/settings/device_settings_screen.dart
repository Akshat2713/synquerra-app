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

class _DeviceSettingsScreenState extends State<DeviceSettingsScreen>
    with TickerProviderStateMixin {
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

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _animationController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<IntervalsProvider>().loadSettingsFromDisk();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
        _showSuccessSnackbar("Device updated successfully");
      }
    } catch (e) {
      debugPrint("Update failed for $key: $e");
      if (mounted) {
        _showErrorSnackbar("Update failed");
      }
    }
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.safeGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.emergencyRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final settings = context.watch<IntervalsProvider>().localSettings;

    String val(String key, String def) => settings[key] ?? def;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          "Device Settings",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 22),
        ),
        backgroundColor: AppColors.navBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Device Selector Card
            _buildDeviceSelectorCard(context),

            const SizedBox(height: 24),

            // Alerts and Safety Section
            _buildSectionHeader(
              context,
              "Alerts & Safety",
              Icons.shield_rounded,
              Colors.blue,
            ),
            const SizedBox(height: 12),
            _buildSettingsCard(
              context: context,
              children: [
                _buildNavigationTile(
                  context: context,
                  icon: Icons.map_rounded,
                  title: "Geofences",
                  subtitle: "Manage safe zones",
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const GeofenceScreen()),
                  ),
                ),
                _buildDivider(context),
                _buildValueTile(
                  context: context,
                  icon: Icons.speed_rounded,
                  title: "Speed Limit",
                  value: val(IntervalPreferences.keySpeedLimit, "70"),
                  unit: "km/h",
                  color: Colors.orange,
                  onTap: () => _showEditDialog(
                    context: context,
                    title: "Set Speed Limit",
                    currentValue: val(IntervalPreferences.keySpeedLimit, "70"),
                    keyboardType: TextInputType.number,
                    valueSuffix: " km/h",
                    onSave: (v) => _updateIntervalSetting(
                      IntervalPreferences.keySpeedLimit,
                      v,
                    ),
                  ),
                ),
                _buildValueTile(
                  context: context,
                  icon: Icons.thermostat_rounded,
                  title: "Temperature Limit",
                  value: val(IntervalPreferences.keyTempLimit, "32"),
                  unit: "°C",
                  color: Colors.red,
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
                _buildValueTile(
                  context: context,
                  icon: Icons.battery_alert_rounded,
                  title: "Low Battery Limit",
                  value: val(IntervalPreferences.keyLowBatLimit, "20"),
                  unit: "%",
                  color: Colors.red,
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

            const SizedBox(height: 24),

            // Intervals Section
            _buildSectionHeader(
              context,
              "Intervals",
              Icons.timer_rounded,
              Colors.purple,
            ),
            const SizedBox(height: 12),
            _buildSettingsCard(
              context: context,
              children: [
                _buildValueTile(
                  context: context,
                  icon: Icons.send_rounded,
                  title: "Normal Sending",
                  value: val(IntervalPreferences.keyNormalSending, "300"),
                  unit: "sec",
                  color: Colors.blue,
                  onTap: () => _showEditDialog(
                    context: context,
                    title: "Normal Sending Interval",
                    currentValue: val(
                      IntervalPreferences.keyNormalSending,
                      "300",
                    ),
                    keyboardType: TextInputType.number,
                    valueSuffix: " sec",
                    onSave: (v) => _updateIntervalSetting(
                      IntervalPreferences.keyNormalSending,
                      v,
                    ),
                  ),
                ),
                _buildDivider(context),
                _buildValueTile(
                  context: context,
                  icon: Icons.warning_rounded,
                  title: "SOS Sending",
                  value: val(IntervalPreferences.keySOSSending, "60"),
                  unit: "sec",
                  color: Colors.red,
                  onTap: () => _showEditDialog(
                    context: context,
                    title: "SOS Sending Interval",
                    currentValue: val(IntervalPreferences.keySOSSending, "60"),
                    keyboardType: TextInputType.number,
                    valueSuffix: " sec",
                    onSave: (v) => _updateIntervalSetting(
                      IntervalPreferences.keySOSSending,
                      v,
                    ),
                  ),
                ),
                _buildDivider(context),
                _buildValueTile(
                  context: context,
                  icon: Icons.gps_fixed_rounded,
                  title: "Normal GPS Scan",
                  value: val(IntervalPreferences.keyNormalScanning, "200"),
                  unit: "sec",
                  color: Colors.green,
                  onTap: () => _showEditDialog(
                    context: context,
                    title: "Normal GPS Scan Interval",
                    currentValue: val(
                      IntervalPreferences.keyNormalScanning,
                      "200",
                    ),
                    keyboardType: TextInputType.number,
                    valueSuffix: " sec",
                    onSave: (v) => _updateIntervalSetting(
                      IntervalPreferences.keyNormalScanning,
                      v,
                    ),
                  ),
                ),
                _buildDivider(context),
                _buildValueTile(
                  context: context,
                  icon: Icons.airplanemode_active_rounded,
                  title: "Aeroplane Scan",
                  value: val(IntervalPreferences.keyAirplane, "300"),
                  unit: "sec",
                  color: Colors.orange,
                  onTap: () => _showEditDialog(
                    context: context,
                    title: "Aeroplane Scan Interval",
                    currentValue: val(IntervalPreferences.keyAirplane, "300"),
                    keyboardType: TextInputType.number,
                    valueSuffix: " sec",
                    onSave: (v) => _updateIntervalSetting(
                      IntervalPreferences.keyAirplane,
                      v,
                    ),
                  ),
                ),
                _buildDivider(context),
                _buildValueTile(
                  context: context,
                  icon: Icons.battery_alert_rounded,
                  title: "Low Battery Data",
                  value: val(IntervalPreferences.keyLowBatData, "900"),
                  unit: "sec",
                  color: Colors.red,
                  onTap: () => _showEditDialog(
                    context: context,
                    title: "Low Battery Data Interval",
                    currentValue: val(IntervalPreferences.keyLowBatData, "900"),
                    keyboardType: TextInputType.number,
                    valueSuffix: " sec",
                    onSave: (v) => _updateIntervalSetting(
                      IntervalPreferences.keyLowBatData,
                      v,
                    ),
                  ),
                ),
                _buildDivider(context),
                _buildValueTile(
                  context: context,
                  icon: Icons.gps_not_fixed_rounded,
                  title: "Low Battery GPS",
                  value: val(IntervalPreferences.keyLowBatGps, "600"),
                  unit: "sec",
                  color: Colors.red,
                  onTap: () => _showEditDialog(
                    context: context,
                    title: "Low Battery GPS Interval",
                    currentValue: val(IntervalPreferences.keyLowBatGps, "600"),
                    keyboardType: TextInputType.number,
                    valueSuffix: " sec",
                    onSave: (v) => _updateIntervalSetting(
                      IntervalPreferences.keyLowBatGps,
                      v,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Hardware Controls Section
            _buildSectionHeader(
              context,
              "Hardware Controls",
              Icons.settings_remote_rounded,
              Colors.teal,
            ),
            const SizedBox(height: 12),
            _buildSettingsCard(
              context: context,
              children: [
                _buildSwitchTile(
                  context: context,
                  icon: Icons.hearing_rounded,
                  title: "Ambient Listening",
                  subtitle: "Microphone always on",
                  value: _ambientListening,
                  onChanged: (v) => setState(() => _ambientListening = v),
                  color: Colors.purple,
                ),
                _buildSwitchTile(
                  context: context,
                  icon: Icons.light_mode_rounded,
                  title: "LED Indicator",
                  subtitle: "Show device status via LED",
                  value: _ledIndicator,
                  onChanged: (v) => setState(() => _ledIndicator = v),
                  color: Colors.amber,
                ),
                _buildSwitchTile(
                  context: context,
                  icon: Icons.airplanemode_active_rounded,
                  title: "Aeroplane Mode",
                  subtitle: "Disable all wireless",
                  value: _aeroplaneMode,
                  onChanged: (v) => setState(() => _aeroplaneMode = v),
                  color: Colors.blue,
                ),
                _buildSwitchTile(
                  context: context,
                  icon: Icons.privacy_tip_rounded,
                  title: "Privacy Mode",
                  subtitle: "Hide location from others",
                  value: _privacyMode,
                  onChanged: (v) => setState(() => _privacyMode = v),
                  color: Colors.green,
                ),
                _buildSwitchTile(
                  context: context,
                  icon: Icons.hide_image_rounded,
                  title: "Incognito Mode",
                  subtitle: "Temporary anonymous mode",
                  value: _incognitoMode,
                  onChanged: (v) => setState(() => _incognitoMode = v),
                  color: Colors.deepOrange,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Version Info Cards
            Row(
              children: [
                Expanded(
                  child: _buildVersionCard(
                    context: context,
                    icon: Icons.memory_rounded,
                    title: "Firmware",
                    version: "1.4.2",
                    buildNumber: "Build-301",
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildVersionCard(
                    context: context,
                    icon: Icons.developer_mode_rounded,
                    title: "Software",
                    version: "3.06.19",
                    buildNumber: "Stable",
                    color: Colors.purple,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceSelectorCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.navBlue.withValues(alpha: 0.1),
            AppColors.navBlue.withValues(alpha: 0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.navBlue.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.navBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.devices_rounded,
                  color: AppColors.navBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                "Select Device",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.only(left: 44),
            child: Text(
              "Choose a device to configure settings",
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.navBlue.withValues(alpha: 0.3),
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedDevice,
                isExpanded: true,
                onChanged: (v) => setState(() => _selectedDevice = v),
                items: _devices.map((d) {
                  return DropdownMenuItem(
                    value: d,
                    child: Row(
                      children: [
                        Icon(
                          Icons.person_rounded,
                          size: 18,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            d,
                            style: TextStyle(color: colorScheme.onSurface),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                style: TextStyle(color: colorScheme.onSurface, fontSize: 15),
                dropdownColor: colorScheme.surface,
                icon: Icon(
                  Icons.arrow_drop_down_rounded,
                  color: AppColors.navBlue,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildSettingsCard({
    required BuildContext context,
    required List<Widget> children,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildValueTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String value,
    required String unit,
    required Color color,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              " $unit",
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.edit_rounded,
              size: 16,
              color: colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: colorScheme.primary, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            )
          : null,
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _buildSwitchTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required Color color,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return SwitchListTile(
      secondary: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: colorScheme.onSurfaceVariant),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: color,
      activeTrackColor: color.withValues(alpha: 0.3),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(
        height: 1,
        color: Theme.of(
          context,
        ).colorScheme.outlineVariant.withValues(alpha: 0.3),
      ),
    );
  }

  Widget _buildVersionCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String version,
    required String buildNumber,
    required Color color,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withValues(alpha: 0.1), Colors.transparent],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            version,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          Text(
            buildNumber,
            style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
