// lib/presentation/pages/profile/widgets/section_label.dart

import 'package:flutter/material.dart';

/// Small all-caps section header used throughout the profile screen.
/// Extracted so it can be reused in other screens without duplication.
class SectionLabel extends StatelessWidget {
  final String text;
  const SectionLabel({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}
