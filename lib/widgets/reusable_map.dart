import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class GeofenceMapPicker extends StatefulWidget {
  final LatLng initialCenter;
  const GeofenceMapPicker({super.key, required this.initialCenter});

  @override
  State<GeofenceMapPicker> createState() => _GeofenceMapPickerState();
}

class _GeofenceMapPickerState extends State<GeofenceMapPicker> {
  final MapController _controller = MapController();
  final List<LatLng> _selectedPoints = [];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      // This forces the dialog to be 10px from sides and 20px from top/bottom
      insetPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias, // Clips the map to the dialog corners
      child: Stack(
        children: [
          // The Map now expands to the full size of the Dialog
          FlutterMap(
            mapController: _controller,
            options: MapOptions(
              initialCenter: widget.initialCenter,
              initialZoom: 16,
              onTap: (tapPos, point) => {
                if (_selectedPoints.length < 5)
                  {setState(() => _selectedPoints.add(point))},
              },
            ),
            // Inside GeofenceMapPicker
            children: [
              TileLayer(
                urlTemplate:
                    'https://api.maptiler.com/maps/openstreetmap/{z}/{x}/{y}.png?key=uOv6PI7AYa13sqD3rQbo',
                userAgentPackageName: 'com.synquerra.app',
              ),
              // Visual Geofence Lines
              if (_selectedPoints.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: [
                        ..._selectedPoints,
                        // If we have 5 points, close the loop back to the first point
                        if (_selectedPoints.length == 5) _selectedPoints[0],
                      ],
                      strokeWidth: 3,
                      color: Colors.blueAccent,
                    ),
                  ],
                ),
              MarkerLayer(
                markers: _selectedPoints.asMap().entries.map((entry) {
                  int idx = entry.key;
                  LatLng p = entry.value;
                  return Marker(
                    point: p,
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(2),
                          color: Colors.white,
                          child: Text(
                            "${idx + 1}",
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        // const Icon(
                        //   Icons.location_on,
                        //   color: Colors.green,
                        //   size: 20,
                        // ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),

          // Instruction Overlay
          Positioned(
            top: 10,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  "Tap to select geofence points",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
          ),

          // Floating Tick Button (Bottom Right)
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              backgroundColor: _selectedPoints.length == 5
                  ? Colors.green
                  : Colors.grey,
              onPressed: _selectedPoints.length == 5
                  ? () => Navigator.pop(context, _selectedPoints)
                  : null,
              child: const Icon(Icons.check, color: Colors.white, size: 30),
            ),
          ),

          Positioned(
            bottom: 20,
            left: 20,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: Colors.redAccent,
              onPressed: () => setState(() => _selectedPoints.clear()),
              child: const Icon(Icons.refresh, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
