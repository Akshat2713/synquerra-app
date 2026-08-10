import 'package:flutter/material.dart';

class MapNumberedMarker extends StatelessWidget {
  final int number;
  final Color backgroundColor;
  final double size;

  const MapNumberedMarker({
    super.key,
    required this.number,
    required this.backgroundColor,
    this.size = 28,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Center(
        child: Text(
          '$number',
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.4,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
