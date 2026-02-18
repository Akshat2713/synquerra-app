// import 'package:flutter/material.dart';
// import 'colors.dart';

// /// Centralized text styles for the entire app
// /// This file handles ONLY text style definitions
// class AppTextStyles {
//   AppTextStyles._(); // Prevent instantiation

//   // ===== HEADINGS =====
//   static const TextStyle heading1 = TextStyle(
//     fontSize: 32,
//     fontWeight: FontWeight.bold,
//     height: 1.2,
//     letterSpacing: -0.5,
//   );

//   static const TextStyle heading2 = TextStyle(
//     fontSize: 28,
//     fontWeight: FontWeight.bold,
//     height: 1.2,
//     letterSpacing: -0.3,
//   );

//   static const TextStyle heading3 = TextStyle(
//     fontSize: 24,
//     fontWeight: FontWeight.w600,
//     height: 1.3,
//   );

//   static const TextStyle heading4 = TextStyle(
//     fontSize: 20,
//     fontWeight: FontWeight.w600,
//     height: 1.3,
//   );

//   static const TextStyle heading5 = TextStyle(
//     fontSize: 18,
//     fontWeight: FontWeight.w600,
//     height: 1.4,
//   );

//   static const TextStyle heading6 = TextStyle(
//     fontSize: 16,
//     fontWeight: FontWeight.w600,
//     height: 1.4,
//   );

//   // ===== BODY TEXT =====
//   static const TextStyle bodyLarge = TextStyle(
//     fontSize: 16,
//     fontWeight: FontWeight.normal,
//     height: 1.5,
//   );

//   static const TextStyle bodyMedium = TextStyle(
//     fontSize: 14,
//     fontWeight: FontWeight.normal,
//     height: 1.5,
//   );

//   static const TextStyle bodySmall = TextStyle(
//     fontSize: 12,
//     fontWeight: FontWeight.normal,
//     height: 1.5,
//   );

//   // ===== CAPTIONS & LABELS =====
//   static const TextStyle caption = TextStyle(
//     fontSize: 12,
//     fontWeight: FontWeight.w400,
//     height: 1.4,
//     letterSpacing: 0.2,
//   );

//   static const TextStyle overline = TextStyle(
//     fontSize: 10,
//     fontWeight: FontWeight.w500,
//     height: 1.4,
//     letterSpacing: 0.5,
//     textBaseline: TextBaseline.alphabetic,
//   );

//   static const TextStyle label = TextStyle(
//     fontSize: 14,
//     fontWeight: FontWeight.w500,
//     height: 1.4,
//   );

//   static const TextStyle labelSmall = TextStyle(
//     fontSize: 12,
//     fontWeight: FontWeight.w500,
//     height: 1.4,
//   );

//   // ===== BUTTON TEXT =====
//   static const TextStyle buttonLarge = TextStyle(
//     fontSize: 16,
//     fontWeight: FontWeight.w600,
//     height: 1.4,
//     letterSpacing: 0.5,
//   );

//   static const TextStyle buttonMedium = TextStyle(
//     fontSize: 14,
//     fontWeight: FontWeight.w600,
//     height: 1.4,
//     letterSpacing: 0.3,
//   );

//   static const TextStyle buttonSmall = TextStyle(
//     fontSize: 12,
//     fontWeight: FontWeight.w600,
//     height: 1.4,
//     letterSpacing: 0.2,
//   );

//   // ===== THEME-AWARE TEXT STYLES =====
//   /// Get heading1 with theme-appropriate color
//   static TextStyle heading1WithColor(BuildContext context, {Color? color}) {
//     return heading1.copyWith(color: color ?? _getPrimaryTextColor(context));
//   }

//   /// Get body text with theme-appropriate color
//   static TextStyle bodyWithColor(BuildContext context, {Color? color}) {
//     return bodyMedium.copyWith(color: color ?? _getSecondaryTextColor(context));
//   }

//   /// Get caption with theme-appropriate color
//   static TextStyle captionWithColor(BuildContext context, {Color? color}) {
//     return caption.copyWith(color: color ?? _getTertiaryTextColor(context));
//   }

//   // ===== PRIVATE HELPER METHODS =====
//   static Color _getPrimaryTextColor(BuildContext context) {
//     return Theme.of(context).brightness == Brightness.dark
//         ? AppColors.darkTextPrimary
//         : AppColors.lightTextPrimary;
//   }

//   static Color _getSecondaryTextColor(BuildContext context) {
//     return Theme.of(context).brightness == Brightness.dark
//         ? AppColors.darkTextSecondary
//         : AppColors.lightTextSecondary;
//   }

//   static Color _getTertiaryTextColor(BuildContext context) {
//     return Theme.of(context).brightness == Brightness.dark
//         ? AppColors.darkTextTertiary
//         : AppColors.lightTextTertiary;
//   }
// }
