// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:latlong2/latlong.dart';
// import 'package:smooth_vehicle_tracker/smooth_vehicle_tracker.dart';

// class SmoothMarkerLayer extends StatelessWidget {
//   final List<LatLng> rawPoints;
//   final int currentIndex;
//   final Widget Function(BuildContext, LatLng, int) markerBuilder;
//   final double lookAheadPoints;

//   const SmoothMarkerLayer({
//     super.key,
//     required this.rawPoints,
//     required this.currentIndex,
//     required this.markerBuilder,
//     this.lookAheadPoints = 3,
//   });

//   @override
//   Widget build(BuildContext context) {
//     if (rawPoints.isEmpty) return const SizedBox.shrink();

//     // Get the current position and smooth it
//     final currentPosition = rawPoints[currentIndex];

//     // Get previous points for direction prediction
//     final startIndex = (currentIndex - lookAheadPoints.toInt()).clamp(
//       0,
//       rawPoints.length - 1,
//     );
//     final endIndex = (currentIndex + lookAheadPoints.toInt()).clamp(
//       0,
//       rawPoints.length - 1,
//     );

//     final windowPoints = rawPoints.sublist(startIndex, endIndex + 1);

//     // Smooth the window
//     final smoothed = SmoothVehicleTracker.smooth(
//       windowPoints,
//       config: const TrackerSmoothingConfig(
//         interpolationPoints: 3,
//         maxSpeed: 120.0,
//       ),
//     );

//     // Get the smoothed position (middle of smoothed window)
//     final smoothedPosition = smoothed.isNotEmpty
//         ? smoothed[smoothed.length ~/ 2]
//         : currentPosition;

//     return MarkerLayer(
//       markers: [
//         Marker(
//           point: smoothedPosition,
//           width: 40,
//           height: 40,
//           anchorPos: AnchorPos.align(AnchorAlign.center),
//           child: markerBuilder(context, smoothedPosition, currentIndex),
//         ),
//       ],
//     );
//   }
// }
