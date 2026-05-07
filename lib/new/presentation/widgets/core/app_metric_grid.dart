// lib/presentation/widgets/core/app_metric_grid.dart
import 'package:flutter/material.dart';

class AppMetricGrid extends StatelessWidget {
  final List<Widget> children;
  final int crossAxisCount;
  final double spacing;
  final double runSpacing;

  const AppMetricGrid({
    super.key,
    required this.children,
    this.crossAxisCount = 4,
    this.spacing = 8,
    this.runSpacing = 8,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: crossAxisCount,
      childAspectRatio: 1,
      crossAxisSpacing: spacing,
      mainAxisSpacing: runSpacing,
      children: children,
    );
  }
}
