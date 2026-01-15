import 'package:flutter/material.dart';
import 'package:synquerra/theme/colors.dart';
import 'package:synquerra/widgets/dummy_screen.dart';

class GeofenceScreen extends StatefulWidget {
  const GeofenceScreen({super.key});

  @override
  State<GeofenceScreen> createState() => _GeofenceScreenState();
}

class _GeofenceScreenState extends State<GeofenceScreen> {
  // State for Geofences
  final List<int> _activeGfs = [1, 2, 3, 7, 8, 9, 13, 15];
  final TextEditingController _countController = TextEditingController(
    text: "15",
  );

  // Reusing your defined styles for consistency
  final TextStyle _underlinedTextStyle = const TextStyle(
    decoration: TextDecoration.underline,
    decorationColor: Colors.grey,
    decorationThickness: 1,
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

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor, // Following theme
      appBar: AppBar(title: const Text("Geofence")),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // --- SECTION 1: Geofence Count & Editor ---
          _buildSectionCard(
            context: context,
            child: Column(
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
                          hintText: "Enter Count",
                          filled: true,
                          fillColor: colorScheme.surfaceContainerHighest
                              .withOpacity(0.5),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {}, // Admin placeholder logic
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.safeGreen,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text("Edit and Save"),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // --- SECTION 2: Statistics & Safe Zones ---
          _buildSectionCard(
            context: context,
            child: Column(
              children: [
                _buildValueRow("Activated Geofence", "5", colorScheme),
                _buildValueRow(
                  "Activated Geofence(Device)",
                  "2/3",
                  colorScheme,
                ),
                _buildValueRow("Safe Zone", "2", colorScheme),
                _buildValueRow("✈ Activated Zone", "1/3", colorScheme),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // --- SECTION 3: Geofence Selection Grid ---
          _buildSectionCard(
            context: context,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Select Geofences to view:",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.bold,
                  ),
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
                  itemBuilder: (context, index) {
                    final id = index + 1;
                    return _buildCheckboxItem(id, colorScheme);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),

          // --- SECTION 4: Action Buttons ---
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DummyScreen(title: "Selected Geofences"),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.navBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
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
                      builder: (_) => DummyScreen(title: "Selected Geofences"),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.navBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text("Show All"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper: Card wrapper matching your reference code
  Widget _buildSectionCard({
    required BuildContext context,
    required Widget child,
  }) {
    return Card(
      elevation: 3,
      color: Theme.of(context).colorScheme.surface, // Theme-aware color
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(padding: const EdgeInsets.all(16.0), child: child),
    );
  }

  // Helper: Row for stats matching your _buildValueRow pattern
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

  // Helper: Checkbox items for the grid
  Widget _buildCheckboxItem(int id, ColorScheme colorScheme) {
    bool isChecked = _activeGfs.contains(id);
    return InkWell(
      onTap: () {
        setState(() {
          isChecked ? _activeGfs.remove(id) : _activeGfs.add(id);
        });
      },
      child: Row(
        children: [
          Checkbox(
            value: isChecked,
            activeColor: AppColors.safeGreen, // Theme consistent green
            onChanged: (val) {
              setState(() {
                val! ? _activeGfs.add(id) : _activeGfs.remove(id);
              });
            },
          ),
          Text("GF$id", style: TextStyle(color: colorScheme.onSurface)),
        ],
      ),
    );
  }
}
