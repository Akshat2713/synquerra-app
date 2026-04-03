import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:synquerra/providers/device_provider.dart';
import 'package:synquerra/theme/colors.dart';
import 'package:synquerra/widgets/dummy_screen.dart';
import 'package:synquerra/widgets/reusable_map.dart';

class GeofenceScreen extends StatefulWidget {
  const GeofenceScreen({super.key});

  @override
  State<GeofenceScreen> createState() => _GeofenceScreenState();
}

class _GeofenceScreenState extends State<GeofenceScreen> {
  // Use a Set for faster lookups and easier toggling
  final List<int> _activeGfs = [1, 2, 3, 7, 8, 9, 13, 15];
  final TextEditingController _countController = TextEditingController(
    text: "15",
  );
  final List<TextEditingController> _xControllers = List.generate(
    5,
    (_) => TextEditingController(),
  );
  final List<TextEditingController> _yControllers = List.generate(
    5,
    (_) => TextEditingController(),
  );

  // final MapController _geofenceMapController = MapController();

  final TextStyle _valueTextStyle = const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.blueAccent,
  );

  @override
  void dispose() {
    for (var c in _xControllers) {
      c.dispose();
    }
    for (var c in _yControllers) {
      c.dispose();
    }
    _countController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(title: const Text("Geofence")),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.navBlue,
        child: const Icon(Icons.add, color: Colors.white, size: 30),
        onPressed: () => _showCreateGeofenceSheet(context),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSectionCard(
            context: context,
            child: _buildCountEditor(theme, colorScheme),
          ),
          const SizedBox(height: 20),
          _buildSectionCard(
            context: context,
            child: _buildStatsSection(colorScheme),
          ),
          const SizedBox(height: 20),
          _buildSectionCard(
            context: context,
            child: _buildSelectionGrid(theme, colorScheme),
          ),
          const SizedBox(height: 30),
          _buildActionButtons(context),
          const SizedBox(height: 16),
          _buildControlButtonsRow(),
        ],
      ),
    );
  }

  // --- 1. MODAL BOTTOM SHEET FOR CREATION ---
  void _showCreateGeofenceSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            _buildSheetHandle(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildFormHeader(),
                    const SizedBox(height: 20),
                    _buildFormFields(),
                    const Divider(height: 40),
                    _buildCoordinateGrid(context),
                    const SizedBox(height: 30),
                    _buildSaveButton(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- 2. FORM & COORDINATE COMPONENTS ---
  Widget _buildFormFields() {
    return Column(
      children: [
        _buildInputField("Profile Name", "Home"),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildInputField("Geofence Number", "3")),
            const SizedBox(width: 12),
            // Matches the image: Safe Zone checkbox next to the label
            Expanded(
              child: Row(
                children: [
                  const Text(
                    "Safe Zone",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  Checkbox(
                    value: true,
                    onChanged: (v) {},
                    activeColor: AppColors.safeGreen,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Full width Geofence ID field
        _buildInputField("Geofence ID", "1665164"),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSwitchTile("Outside access", true),
            _buildSwitchTile("Incognito", true),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSwitchTile("Aeroplane Activate", true),
            _buildSwitchTile("Privacy Zone", true),
          ],
        ),
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //   children: [
        //     _buildSwitchTile("Default Time", true),
        //     _buildSwitchTile("Accl.", true),
        //   ],
        // ),
      ],
    );
  }

  Widget _buildCoordinateGrid(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Co-ordinates",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 15),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                GestureDetector(
                  onTap: () async {
                    // Get location from Provider
                    final telemetry = context
                        .read<DeviceProvider>()
                        .latestTelemetry;
                    final center = (telemetry?.latitude != null)
                        ? LatLng(telemetry!.latitude!, telemetry.longitude!)
                        : const LatLng(28.3702, 77.1236);

                    // Open the Square Widget Dialog
                    final List<LatLng>? results = await showDialog(
                      context: context,
                      builder: (context) =>
                          GeofenceMapPicker(initialCenter: center),
                    );

                    if (results != null && results.isNotEmpty) {
                      setState(() {
                        for (int i = 0; i < results.length && i < 5; i++) {
                          _xControllers[i].text = results[i].latitude
                              .toStringAsFixed(6);
                          _yControllers[i].text = results[i].longitude
                              .toStringAsFixed(6);
                        }
                      });
                    }
                  },
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green, width: 2),
                    ),
                    child: const Icon(
                      Icons.location_on,
                      size: 50,
                      color: Colors.green,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Choose from map",
                  style: TextStyle(fontSize: 11, color: Colors.green),
                ),
              ],
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                children: List.generate(
                  5,
                  (index) => _buildCoordRow(index + 1),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Widget _buildCoordinateGrid(BuildContext context) {
  //   // Get current device location from Provider
  //   final deviceLatLng = context.read<DeviceProvider>().latestTelemetry;
  //   final LatLng initialPos = deviceLatLng?.latitude != null
  //       ? LatLng(deviceLatLng!.latitude!, deviceLatLng!.longitude!)
  //       : const LatLng(28.3702, 77.1236);

  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       const Text(
  //         "Co-ordinates",
  //         style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
  //       ),
  //       const SizedBox(height: 15),
  //       Row(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Column(
  //             children: [
  //               GestureDetector(
  //                 onTap: () => Navigator.push(
  //                   context,
  //                   MaterialPageRoute(
  //                     builder: (context) =>
  //                         FullScreenMapSelector(initialCenter: initialPos),
  //                   ),
  //                 ),
  //                 child: Container(
  //                   width: 100,
  //                   height: 100,
  //                   decoration: BoxDecoration(
  //                     color: Colors.green.withOpacity(0.1),
  //                     borderRadius: BorderRadius.circular(12),
  //                     border: Border.all(color: Colors.green, width: 2),
  //                   ),
  //                   child: const Icon(
  //                     Icons.location_on,
  //                     size: 50,
  //                     color: Colors.green,
  //                   ),
  //                 ),
  //               ),
  //               const SizedBox(height: 8),
  //               const Text(
  //                 "Choose from map",
  //                 style: TextStyle(fontSize: 11, color: Colors.green),
  //               ),
  //             ],
  //           ),
  //           const SizedBox(width: 15),
  //           Expanded(
  //             child: Column(
  //               children: List.generate(
  //                 5,
  //                 (index) => _buildCoordRow(index + 1),
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ],
  //   );
  // }

  // --- 3. MAIN SCREEN CONTROL BUTTONS ---
  Widget _buildControlButtonsRow() {
    return Row(
      children: [
        _buildSmallControlButton("Edit", Colors.blue),
        _buildSmallControlButton(
          "Reset",
          Colors.white,
          textColor: Colors.black,
        ),
        _buildSmallControlButton("Delete", Colors.red),
      ],
    );
  }

  Widget _buildSmallControlButton(
    String label,
    Color color, {
    Color textColor = Colors.white,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: textColor,
            elevation: 2,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            side: color == Colors.white
                ? const BorderSide(color: Colors.grey)
                : null,
          ),
          onPressed: () {},
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  // --- 4. HELPER WIDGETS ---
  Widget _buildInputField(String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 6),
        TextField(
          decoration: InputDecoration(
            hintText: hint,
            isDense: true,
            filled: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchTile(String title, bool val) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title, style: const TextStyle(fontSize: 13)),
        Switch(
          value: val,
          onChanged: (v) {},
          activeThumbColor: AppColors.safeGreen,
        ),
      ],
    );
  }

  Widget _buildCoordRow(int i) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        children: [
          Text(
            "X$i:",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          const SizedBox(width: 4),
          Expanded(child: _buildMiniField(_xControllers[i - 1])),
          const SizedBox(width: 8),
          Text(
            "Y$i:",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          const SizedBox(width: 4),
          Expanded(child: _buildMiniField(_yControllers[i - 1])),
        ],
      ),
    );
  }

  Widget _buildMiniField(TextEditingController controller) {
    return SizedBox(
      height: 30,
      child: TextField(
        controller: controller,
        style: TextStyle(fontSize: 12),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 4),
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.safeGreen,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        onPressed: () => Navigator.pop(context),
        child: const Text(
          "Save Geofence",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required BuildContext context,
    required Widget child,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(padding: const EdgeInsets.all(16.0), child: child),
    );
  }

  Widget _buildCountEditor(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Geofence Count", style: theme.textTheme.titleMedium),
            Text("15", style: _valueTextStyle),
          ],
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _countController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.safeGreen,
                foregroundColor: Colors.white,
              ),
              child: const Text("Edit and Save"),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsSection(ColorScheme colorScheme) {
    return Column(
      children: [
        _buildValueRow("Activated Geofence", "5", colorScheme),
        _buildValueRow("Safe Zone", "2", colorScheme),
        _buildValueRow("✈ Activated Zone", "1/3", colorScheme),
        _buildValueRow("Privacy Zone", "3", colorScheme),
      ],
    );
  }

  Widget _buildValueRow(String title, String value, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(color: colorScheme.onSurface, fontSize: 16),
          ),
          Text(value, style: _valueTextStyle),
        ],
      ),
    );
  }

  Widget _buildSelectionGrid(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Select Geofences to view:",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 2.2,
          ),
          itemCount: 15,
          itemBuilder: (context, index) =>
              _buildCheckboxItem(index + 1, colorScheme),
        ),
      ],
    );
  }

  // --- REPAIRED: Interactive Checkbox Logic ---
  Widget _buildCheckboxItem(int id, ColorScheme colorScheme) {
    bool isChecked = _activeGfs.contains(id);
    return Row(
      children: [
        Checkbox(
          value: isChecked,
          activeColor: AppColors.safeGreen,
          onChanged: (bool? newValue) {
            setState(() {
              if (newValue == true) {
                _activeGfs.add(id);
              } else {
                _activeGfs.remove(id);
              }
            });
          },
        ),
        Text("GF$id"),
      ],
    );
  }

  // --- REPAIRED: Show / Show All Navigation Logic ---
  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const DummyScreen(title: "Selected Geofences"),
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.navBlue,
              foregroundColor: Colors.white,
            ),
            child: const Text("Show"),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const DummyScreen(title: "All Geofences"),
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.navBlue,
              foregroundColor: Colors.white,
            ),
            child: const Text("Show All"),
          ),
        ),
      ],
    );
  }

  Widget _buildSheetHandle() {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 10),
        width: 40,
        height: 5,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildFormHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Create Geofence",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close),
        ),
      ],
    );
  }
}
