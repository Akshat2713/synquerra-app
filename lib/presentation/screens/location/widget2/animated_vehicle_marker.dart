// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:latlong2/latlong.dart';
// import 'package:smooth_vehicle_tracker/smooth_vehicle_tracker.dart';

// class AnimatedVehicleMarker extends StatefulWidget {
//   final List<LatLng> points;
//   final int currentIndex;
//   final void Function(LatLng position, double bearing)? onPositionChanged;

//   const AnimatedVehicleMarker({
//     super.key,
//     required this.points,
//     required this.currentIndex,
//     this.onPositionChanged,
//   });

//   @override
//   State<AnimatedVehicleMarker> createState() => _AnimatedVehicleMarkerState();
// }

// class _AnimatedVehicleMarkerState extends State<AnimatedVehicleMarker>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   LatLng? _currentPosition;
//   double _currentBearing = 0;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 500),
//     );
//     _updatePosition();
//   }

//   @override
//   void didUpdateWidget(AnimatedVehicleMarker oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (oldWidget.currentIndex != widget.currentIndex ||
//         oldWidget.points != widget.points) {
//       _updatePosition();
//     }
//   }

//   void _updatePosition() {
//     if (widget.points.isEmpty) return;

//     final currentPos = widget.points[widget.currentIndex];
//     final hasPrevious = widget.currentIndex > 0;
//     final hasNext = widget.currentIndex < widget.points.length - 1;

//     // Calculate bearing
//     if (hasNext) {
//       final nextPos = widget.points[widget.currentIndex + 1];
//       _currentBearing = _calculateBearing(currentPos, nextPos);
//     } else if (hasPrevious) {
//       final prevPos = widget.points[widget.currentIndex - 1];
//       _currentBearing = _calculateBearing(prevPos, currentPos);
//     }

//     setState(() {
//       _currentPosition = currentPos;
//     });

//     widget.onPositionChanged?.call(currentPos, _currentBearing);
//     _controller.forward(from: 0);
//   }

//   double _calculateBearing(LatLng from, LatLng to) {
//     final lat1 = from.latitude * 3.14159 / 180;
//     final lat2 = to.latitude * 3.14159 / 180;
//     final dLon = (to.longitude - from.longitude) * 3.14159 / 180;

//     final x = dLon * (lat1 + lat2) / 2;
//     final y = lat2 - lat1;

//     return (x * 180 / 3.14159).clamp(-180, 180);
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_currentPosition == null) return const SizedBox.shrink();

//     return AnimatedBuilder(
//       animation: _controller,
//       builder: (context, child) {
//         return Transform.rotate(
//           angle: _currentBearing * 3.14159 / 180,
//           child: Container(
//             width: 32,
//             height: 32,
//             decoration: BoxDecoration(
//               color: Colors.blue,
//               shape: BoxShape.circle,
//               border: Border.all(color: Colors.white, width: 2),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.blue.withOpacity(0.5),
//                   blurRadius: 8,
//                   spreadRadius: 2,
//                 ),
//               ],
//             ),
//             child: const Icon(
//               Icons.navigation,
//               color: Colors.white,
//               size: 16,
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
