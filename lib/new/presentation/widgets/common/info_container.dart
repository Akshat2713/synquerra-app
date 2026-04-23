import 'package:flutter/material.dart';

// The main container for a section of details
class InfoContainer extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final Color? accentColor; // Optional accent color for the header
  final bool hasBorder; // Whether to show a border

  const InfoContainer({
    super.key,
    required this.title,
    required this.children,
    this.accentColor,
    this.hasBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accent = accentColor ?? colorScheme.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: hasBorder
            ? Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                width: 1,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with accent line
          if (title.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 24,
                    decoration: BoxDecoration(
                      color: accent,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, thickness: 1, indent: 20, endIndent: 20),
          ],
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }
}

// // The perfectly aligned row for a single piece of information
// class DetailRow extends StatelessWidget {
//   final IconData icon;
//   final String title;
//   final String value;
//   final Color? iconColor;
//   final Color? valueColor;
//   final bool isCompact; // For tighter spacing
//   final Widget? customValue; // For custom value widgets instead of text

//   const DetailRow({
//     super.key,
//     required this.icon,
//     required this.title,
//     required this.value,
//     this.iconColor,
//     this.valueColor,
//     this.isCompact = false,
//     this.customValue,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final colorScheme = Theme.of(context).colorScheme;
//     final iconBgColor = (iconColor ?? colorScheme.primary).withValues(
//       alpha: 0.1,
//     );

//     return Padding(
//       padding: EdgeInsets.only(bottom: isCompact ? 8.0 : 12.0),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           // Icon with background
//           Container(
//             padding: const EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color: iconBgColor,
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: Icon(
//               icon,
//               size: 16,
//               color: iconColor ?? colorScheme.primary,
//             ),
//           ),
//           const SizedBox(width: 12),
//           // Title with fixed width
//           SizedBox(
//             width: 120,
//             child: Text(
//               title,
//               style: TextStyle(
//                 fontSize: 14,
//                 color: colorScheme.onSurfaceVariant,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//           const SizedBox(width: 8),
//           // Value
//           Expanded(
//             child:
//                 customValue ??
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 12,
//                     vertical: 6,
//                   ),
//                   decoration: BoxDecoration(
//                     color: colorScheme.surfaceContainerHighest.withValues(
//                       alpha: 0.2,
//                     ),
//                     borderRadius: BorderRadius.circular(30),
//                   ),
//                   child: Text(
//                     value,
//                     style: TextStyle(
//                       fontSize: 14,
//                       fontWeight: FontWeight.w600,
//                       color: valueColor ?? colorScheme.onSurface,
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                 ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // A chip-style metric display for compact layouts
// class MetricChip extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final String value;
//   final Color color;

//   const MetricChip({
//     super.key,
//     required this.icon,
//     required this.label,
//     required this.value,
//     required this.color,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final colorScheme = Theme.of(context).colorScheme;

//     return Container(
//       padding: const EdgeInsets.symmetric(vertical: 12),
//       decoration: BoxDecoration(
//         color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(
//           color: colorScheme.outlineVariant.withValues(alpha: 0.2),
//         ),
//       ),
//       child: Column(
//         children: [
//           Icon(icon, color: color, size: 20),
//           const SizedBox(height: 4),
//           Text(
//             value,
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//               color: colorScheme.onSurface,
//             ),
//           ),
//           Text(
//             label,
//             style: TextStyle(fontSize: 10, color: colorScheme.onSurfaceVariant),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // A status indicator with colored dot
// class StatusIndicator extends StatelessWidget {
//   final String label;
//   final String value;
//   final Color color;
//   final bool isActive;

//   const StatusIndicator({
//     super.key,
//     required this.label,
//     required this.value,
//     required this.color,
//     this.isActive = true,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final colorScheme = Theme.of(context).colorScheme;

//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//       decoration: BoxDecoration(
//         color: color.withValues(alpha: 0.1),
//         borderRadius: BorderRadius.circular(30),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Container(
//             width: 8,
//             height: 8,
//             decoration: BoxDecoration(
//               color: isActive ? color : Colors.grey,
//               shape: BoxShape.circle,
//               boxShadow: [
//                 if (isActive)
//                   BoxShadow(
//                     color: color.withValues(alpha: 0.4),
//                     blurRadius: 4,
//                     spreadRadius: 1,
//                   ),
//               ],
//             ),
//           ),
//           const SizedBox(width: 6),
//           Text(
//             label,
//             style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant),
//           ),
//           const SizedBox(width: 4),
//           Text(
//             value,
//             style: TextStyle(
//               fontSize: 11,
//               fontWeight: FontWeight.bold,
//               color: color,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // A section divider with optional title
// class SectionDivider extends StatelessWidget {
//   final String? title;
//   final IconData? icon;

//   const SectionDivider({super.key, this.title, this.icon});

//   @override
//   Widget build(BuildContext context) {
//     final colorScheme = Theme.of(context).colorScheme;

//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 16),
//       child: Row(
//         children: [
//           if (icon != null) ...[
//             Container(
//               padding: const EdgeInsets.all(6),
//               decoration: BoxDecoration(
//                 color: colorScheme.primary.withValues(alpha: 0.1),
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(icon, size: 14, color: colorScheme.primary),
//             ),
//             const SizedBox(width: 10),
//           ],
//           if (title != null)
//             Text(
//               title!,
//               style: TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w600,
//                 color: colorScheme.primary,
//                 letterSpacing: 0.3,
//               ),
//             ),
//           Expanded(
//             child: Container(
//               margin: const EdgeInsets.only(left: 10),
//               height: 1,
//               color: colorScheme.outlineVariant.withValues(alpha: 0.3),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
