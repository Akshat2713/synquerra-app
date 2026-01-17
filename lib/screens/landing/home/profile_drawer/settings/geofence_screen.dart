import 'package:flutter/material.dart';
import 'package:synquerra/theme/colors.dart';
import 'package:synquerra/widgets/dummy_screen.dart';

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

  final TextStyle _valueTextStyle = const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.blueAccent,
  );

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
            Expanded(child: _buildInputField("Geofence ID", "1665164")),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSwitchTile("Outside Access", true),
            _buildSwitchTile("Incognito", true),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSwitchTile("Privacy Zone", true),
            _buildSwitchTile("Safe Zone", true),
          ],
        ),
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
                Container(
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
                const SizedBox(height: 8),
                const Text(
                  "Choose from map",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                children: List.generate(5, (index) => _buildCoordRow(index)),
              ),
            ),
          ],
        ),
      ],
    );
  }

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
        Switch(value: val, onChanged: (v) {}, activeColor: AppColors.safeGreen),
      ],
    );
  }

  Widget _buildCoordRow(int i) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          const Text("X:", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 4),
          Expanded(child: _buildMiniField()),
          const SizedBox(width: 10),
          const Text("Y:", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 4),
          Expanded(child: _buildMiniField()),
        ],
      ),
    );
  }

  Widget _buildMiniField() {
    return const SizedBox(
      height: 30,
      child: TextField(
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
