// import 'package:flutter/material.dart';

// import '../../../themes/colors.dart';
// import 'package:synquerra/presentation/themes/app_tokens.dart';

// class GeofenceSyncToggle extends StatelessWidget {
//   final bool isSyncToDevice;
//   final ValueChanged<bool> onChanged;

//   const GeofenceSyncToggle({
//     super.key,
//     required this.isSyncToDevice,
//     required this.onChanged,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final textTheme = Theme.of(context).textTheme;

//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       decoration: BoxDecoration(
//         border: Border.all(color: AppColors.outline(context)),
//         borderRadius: AppRadius.mdAll,
//       ),
//       child: Row(
//         children: [
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Sync to device',
//                   style: textTheme.bodyMedium?.copyWith(
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//                 Text(
//                   'Geofence will be sent to the device',
//                   style: textTheme.bodySmall?.copyWith(
//                     color: AppColors.textSecondary(context),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Switch(
//             value: isSyncToDevice,
//             onChanged: onChanged,
//             activeTrackColor: AppColors.success,
//             activeThumbColor: AppColors.onSuccess,
//             inactiveThumbColor: AppColors.onDanger,
//           ),
//         ],
//       ),
//     );
//   }
// }
