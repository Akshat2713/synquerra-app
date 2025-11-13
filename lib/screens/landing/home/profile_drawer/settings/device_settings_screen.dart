import 'package:flutter/material.dart';
import 'package:safe_track/widgets/edit_value_dialog.dart'; // Import the new dialog
import 'package:safe_track/theme/colors.dart'; // Import AppColors if needed, e.g., for AppColors.safeGreen
import 'package:safe_track/widgets/dummy_screen.dart';

class DeviceSettingsScreen extends StatefulWidget {
  const DeviceSettingsScreen({super.key});

  @override
  State<DeviceSettingsScreen> createState() => _DeviceSettingsScreenState();
}

class _DeviceSettingsScreenState extends State<DeviceSettingsScreen> {
  // --- State Variables ---
  String? _selectedDevice =
      'Rahul Kumar (f5v11vfx)'; // Initial value for dropdown
  final List<String> _devices = [
    'Rahul Kumar (f5v11vfx)',
    'Anjali Sharma (g8h22wgy)',
    'Office Tracker (z1k99abc)',
    'Dad\'s Car (h4j55xyz)',
    'Mom\'s Phone (p9q88lmn)',
  ]; // Example devices

  // Editable Values
  String _speedLimit = "70 KM/hr"; // Initial value set here
  String _tempLimit = "32°C"; // Initial value set here
  String _normalInterval = "300s";
  String _sosInterval = "60s";
  String _gpsInterval = "200s";
  String _aeroplaneInterval = "300s";
  String _lowBatDataInterval = "900s";
  String _lowBatGpsInterval = "600s";

  bool _ambientListening = true;
  bool _ledIndicator = true;

  // --- Helper Methods ---
  void _navigateToDummy(BuildContext context, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DummyScreen(title: title)),
    );
  }

  // Method to show the edit dialog
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
          onSave: onSave, // Pass the callback directly
          keyboardType: keyboardType,
          valueSuffix: valueSuffix,
        );
      },
    );
  }

  // Helper for underlined text style
  final TextStyle _underlinedTextStyle = const TextStyle(
    decoration: TextDecoration.underline,
    decorationColor: Colors.grey, // Adjust underline color if needed
    decorationThickness: 1,
    fontSize: 17,
    fontWeight: FontWeight.w500,
  );

  // Helper style for normal clickable text in sections
  final TextStyle _clickableTextStyle = const TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w500,
  );

  // Helper style for the blue value text
  final TextStyle _valueTextStyle = const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.blueAccent, // Color from the image
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text("Device Settings")),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // --- Choose Device Section ---
          Padding(
            padding: const EdgeInsets.only(bottom: 15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      color: colorScheme.primary,
                      size: 28,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Choose a device",
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 36.0,
                  ), // Indent under icon
                  child: Text(
                    "to view setting of that device",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // --- Standard DropdownButton with Decoration ---
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 4.0,
                  ), // Padding inside container
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withOpacity(
                      0.5,
                    ), // Subtle background
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(
                      color: colorScheme.outlineVariant,
                    ), // Border
                  ),
                  child: DropdownButtonHideUnderline(
                    // Remove default underline
                    child: DropdownButton<String>(
                      value: _selectedDevice,
                      isExpanded: true, // Make dropdown take available width
                      icon: Icon(
                        Icons.arrow_drop_down,
                        color: colorScheme.onSurfaceVariant,
                      ), // Arrow icon
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurface,
                      ), // Text style for selected item
                      dropdownColor: colorScheme
                          .surfaceContainerHighest, // Background color of the dropdown menu
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedDevice = newValue;
                        });
                        // TODO: Add logic to load settings for the selected device
                        print('Selected device: $newValue');
                      },
                      items: _devices.map<DropdownMenuItem<String>>((
                        String value,
                      ) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                            // Optional: Style for items in the dropdown list
                            // style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                // --- End Standard DropdownButton ---
              ],
            ),
          ),

          // --- Alerts and Safety Section ---
          _buildSectionCard(
            context: context,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  // Title with Icon
                  children: [
                    Icon(
                      Icons.shield_outlined,
                      color: colorScheme.primary,
                      size: 28,
                    ), // Added icon
                    const SizedBox(width: 8),
                    Text(
                      "Alerts and Safety",
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                _buildNavigationRow(
                  context: context,
                  titleWidget: Text(
                    "Geofences",
                    style: _underlinedTextStyle.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ), // Theme aware color
                  onTap: () => _navigateToDummy(context, "Geofences"),
                ),
                _buildValueRow(
                  context: context,
                  titleWidget: Text(
                    "Speed Limit",
                    style: _underlinedTextStyle.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ), // Theme aware color
                  value: _speedLimit, // Use state variable
                  valueStyle: _valueTextStyle,
                  onTap: () => _showEditDialog(
                    // Show dialog on tap
                    context: context,
                    title: "Set Speed Limit",
                    currentValue: _speedLimit,
                    keyboardType: TextInputType.number,
                    valueSuffix: " KM/hr",
                    onSave: (newValue) =>
                        setState(() => _speedLimit = newValue),
                  ),
                ),
                _buildValueRow(
                  context: context,
                  titleWidget: Text(
                    "Temperature Limit",
                    style: _clickableTextStyle.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ), // Theme aware color
                  value: _tempLimit, // Use state variable
                  valueStyle: _valueTextStyle,
                  onTap: () => _showEditDialog(
                    // Show dialog on tap
                    context: context,
                    title: "Set Temperature Limit",
                    currentValue: _tempLimit,
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    valueSuffix: "°C",
                    onSave: (newValue) => setState(() => _tempLimit = newValue),
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
                Row(
                  // Title with Icon
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      color: colorScheme.primary,
                      size: 28,
                    ), // Added icon
                    const SizedBox(width: 8),
                    Text(
                      "Intervals",
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                _buildValueRow(
                  context: context,
                  titleWidget: Text(
                    "Normal Sending Interval",
                    style: _clickableTextStyle.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                  value: _normalInterval,
                  valueStyle: _valueTextStyle,
                  onTap: () => _showEditDialog(
                    context: context,
                    title: "Normal Sending Interval",
                    currentValue: _normalInterval,
                    keyboardType: TextInputType.number,
                    valueSuffix: "s",
                    onSave: (newValue) =>
                        setState(() => _normalInterval = newValue),
                  ),
                ),
                _buildValueRow(
                  context: context,
                  titleWidget: Text(
                    "SOS Sending Interval",
                    style: _clickableTextStyle.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                  value: _sosInterval,
                  valueStyle: _valueTextStyle,
                  onTap: () => _showEditDialog(
                    context: context,
                    title: "SOS Sending Interval",
                    currentValue: _sosInterval,
                    keyboardType: TextInputType.number,
                    valueSuffix: "s",
                    onSave: (newValue) =>
                        setState(() => _sosInterval = newValue),
                  ),
                ),
                _buildValueRow(
                  context: context,
                  titleWidget: Text(
                    "Normal GPS Sending Interval (>4)",
                    style: _clickableTextStyle.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                  value: _gpsInterval,
                  valueStyle: _valueTextStyle,
                  onTap: () => _showEditDialog(
                    context: context,
                    title: "Normal GPS Sending Interval",
                    currentValue: _gpsInterval,
                    keyboardType: TextInputType.number,
                    valueSuffix: "s",
                    onSave: (newValue) =>
                        setState(() => _gpsInterval = newValue),
                  ),
                ),
                _buildValueRow(
                  context: context,
                  titleWidget: Text(
                    "Aeroplane Scan Interval",
                    style: _clickableTextStyle.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                  value: _aeroplaneInterval,
                  valueStyle: _valueTextStyle,
                  onTap: () => _showEditDialog(
                    context: context,
                    title: "Aeroplane Scan Interval",
                    currentValue: _aeroplaneInterval,
                    keyboardType: TextInputType.number,
                    valueSuffix: "s",
                    onSave: (newValue) =>
                        setState(() => _aeroplaneInterval = newValue),
                  ),
                ),
                _buildValueRow(
                  context: context,
                  titleWidget: Text(
                    "Low battery Data Sending Interval",
                    style: _clickableTextStyle.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                  value: _lowBatDataInterval,
                  valueStyle: _valueTextStyle,
                  onTap: () => _showEditDialog(
                    context: context,
                    title: "Low Battery Data Interval",
                    currentValue: _lowBatDataInterval,
                    keyboardType: TextInputType.number,
                    valueSuffix: "s",
                    onSave: (newValue) =>
                        setState(() => _lowBatDataInterval = newValue),
                  ),
                ),
                _buildValueRow(
                  context: context,
                  titleWidget: Text(
                    "Low battery GPS Sending Interval",
                    style: _clickableTextStyle.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                  value: _lowBatGpsInterval,
                  valueStyle: _valueTextStyle,
                  onTap: () => _showEditDialog(
                    context: context,
                    title: "Low Battery GPS Interval",
                    currentValue: _lowBatGpsInterval,
                    keyboardType: TextInputType.number,
                    valueSuffix: "s",
                    onSave: (newValue) =>
                        setState(() => _lowBatGpsInterval = newValue),
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
                Row(
                  children: [
                    Icon(
                      Icons.settings_remote_outlined,
                      color: colorScheme.primary,
                      size: 28,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Hardware Controls",
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                _buildSwitchRow(
                  context: context,
                  title: "Ambient Listening",
                  value: _ambientListening,
                  onChanged: (value) =>
                      setState(() => _ambientListening = value),
                ),
                _buildSwitchRow(
                  context: context,
                  title: "LED Indicator",
                  value: _ledIndicator,
                  onChanged: (value) => setState(() => _ledIndicator = value),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // --- Firmware Version Section ---
          _buildVersionCard(
            context: context,
            icon: Icons.memory_outlined,
            title: "Firmware version",
            version: "1.4.2-Build-301",
          ),
          const SizedBox(height: 20),

          // --- Software Version Section ---
          _buildVersionCard(
            context: context,
            icon: Icons.developer_mode_outlined,
            title: "Software version",
            version: "3.06.19",
          ),
        ],
      ),
    );
  }

  // --- Helper Widgets ---

  // Helper for the main section cards (borders removed)
  Widget _buildSectionCard({
    required BuildContext context,
    required Widget child,
  }) {
    return Card(
      elevation: 4,
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        // REMOVED: side: BorderSide(...)
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
        child: child,
      ),
    );
  }

  // Helper for rows with text and a trailing value (clickable)
  Widget _buildValueRow({
    required BuildContext context,
    Widget? titleWidget,
    String? title,
    required String value,
    TextStyle? valueStyle,
    VoidCallback? onTap, // Make sure this is passed if needed by dialog
  }) {
    assert(
      title != null || titleWidget != null,
      'Provide either title or titleWidget',
    );
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Use titleWidget if provided, otherwise create Text from title
            titleWidget ??
                Text(
                  title!,
                  style: _clickableTextStyle.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
            Text(
              value,
              style:
                  valueStyle ??
                  _valueTextStyle.copyWith(color: colorScheme.secondary),
            ), // Example: using secondary color
          ],
        ),
      ),
    );
  }

  // Helper for rows with text and a trailing arrow (clickable)
  Widget _buildNavigationRow({
    required BuildContext context,
    Widget? titleWidget,
    String? title,
    VoidCallback? onTap,
  }) {
    assert(
      title != null || titleWidget != null,
      'Provide either title or titleWidget',
    );
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Use titleWidget if provided, otherwise create Text from title
            titleWidget ??
                Text(
                  title!,
                  style: _underlinedTextStyle.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
            Icon(
              Icons.chevron_right,
              color: colorScheme.onSurfaceVariant.withOpacity(0.7),
            ),
          ],
        ),
      ),
    );
  }

  // Helper for rows with text and a trailing switch
  Widget _buildSwitchRow({
    required BuildContext context,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: _clickableTextStyle.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.safeGreen, // Using specific green
            // inactiveTrackColor: theme.colorScheme.surfaceVariant, // Optional: customize inactive color
            // inactiveThumbColor: theme.colorScheme.outline, // Optional: customize inactive color
          ),
        ],
      ),
    );
  }

  // Helper for the version cards at the bottom (borders removed)
  Widget _buildVersionCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String version,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Card(
      elevation: 4,
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        // REMOVED: side: BorderSide(...)
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
        child: Row(
          children: [
            Icon(icon, color: colorScheme.primary, size: 28),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  version,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
