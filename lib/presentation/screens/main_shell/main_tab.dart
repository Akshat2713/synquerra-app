// lib/presentation/screens/main_shell/main_tab.dart
import 'package:flutter/widgets.dart';

/// Data-only descriptor for one bottom-navigation tab.
class MainTab {
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final WidgetBuilder builder;

  const MainTab({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.builder,
  });
}
