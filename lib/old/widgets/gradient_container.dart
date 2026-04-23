import 'package:flutter/material.dart';

class GradientContainer extends StatelessWidget {
  final Widget child;
  final List<Color> colors;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final List<double>? stops;
  final Alignment begin;
  final Alignment end;

  const GradientContainer({
    super.key,
    required this.child,
    required this.colors,
    this.borderRadius = 16,
    this.padding = EdgeInsets.zero,
    this.stops,
    this.begin = Alignment.centerLeft,
    this.end = Alignment.centerRight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          stops: stops,
          begin: begin,
          end: end,
        ),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: child,
    );
  }
}
