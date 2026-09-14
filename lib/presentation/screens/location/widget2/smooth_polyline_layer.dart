// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:latlong2/latlong.dart';
// import 'package:smooth_vehicle_tracker/smooth_vehicle_tracker.dart';

// class SmoothPolylineLayer extends StatelessWidget {
//   final List<LatLng> rawPoints;
//   final Color color;
//   final double strokeWidth;
//   final bool animate;

//   const SmoothPolylineLayer({
//     super.key,
//     required this.rawPoints,
//     this.color = Colors.blue,
//     this.strokeWidth = 3.0,
//     this.animate = true,
//   });

//   @override
//   Widget build(BuildContext context) {
//     if (rawPoints.length < 2) {
//       // Show single marker for single point
//       return const SizedBox.shrink();
//     }

//     // Create smoothing config
//     final config = TrackerSmoothingConfig(
//       maxSpeed: 120.0, // km/h - adjust based on your device
//       snapToRoad: false, // Set true if you have map matching
//       interpolationPoints: 5, // Points between each raw point
//       minDistance: 5.0, // meters - ignore micro-movements
//     );

//     // Smooth the points
//     final smoothedPoints = SmoothVehicleTracker.smooth(
//       rawPoints,
//       config: config,
//     );

//     return PolylineLayer(
//       polylines: [
//         Polyline(
//           points: animate ? smoothedPoints : rawPoints,
//           color: color,
//           strokeWidth: strokeWidth,
//           borderStrokeWidth: 1.0,
//           borderColor: Colors.white.withOpacity(0.3),
//           isDotted: false,
//         ),
//       ],
//     );
//   }
// }
