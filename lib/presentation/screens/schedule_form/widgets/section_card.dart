import 'package:flutter/material.dart';
import 'package:synquerra/presentation/themes/colors.dart';
import 'package:synquerra/presentation/themes/app_tokens.dart';

class SectionCard extends StatelessWidget {
  final List<Widget> children;

  const SectionCard({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: AppRadius.lgAll,
        border: Border.all(color: AppColors.outline(context)),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: AppRadius.lgAll,
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ),
    );
  }
}
