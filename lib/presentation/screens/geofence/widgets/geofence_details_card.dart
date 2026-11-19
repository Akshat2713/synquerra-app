import 'package:flutter/material.dart';

import '../../../themes/app_text_styles.dart';
import '../../../themes/app_tokens.dart';
import '../../../themes/colors.dart';
import '../../../utils/app_icons.dart';
import '../../../widgets/app_section_card.dart';
import '../../../widgets/app_surfaces.dart';
import 'geofence_address_section.dart';

/// Name + collapsible address + active switch.
class GeofenceDetailsCard extends StatelessWidget {
  final TextEditingController controller;
  final GeofenceAddressFields addressFields;
  final bool isActive;
  final ValueChanged<bool> onActiveChanged;

  const GeofenceDetailsCard({
    super.key,
    required this.controller,
    required this.addressFields,
    required this.isActive,
    required this.onActiveChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(
      title: 'Details',
      icon: AppIcons.geofence,
      background: AppColors.primary(context),
      foreground: AppColors.onPrimary(context),
      children: [
        TextFormField(
          controller: controller,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            labelText: 'Geofence name',
            hintText: 'e.g. School Zone',
            prefixIcon: Icon(
              AppIcons.title,
              size: AppSize.icon,
              color: AppColors.textSecondary(context),
            ),
          ),
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Name is required' : null,
        ),
        GeofenceAddressSection(fields: addressFields),
        InsetRow(
          onTap: () => onActiveChanged(!isActive),
          child: Row(
            spacing: AppSpacing.sm,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Active',
                      style: AppTextStyles.bodyWithColor(
                        context,
                        color: AppColors.textPrimary(context),
                      ).copyWith(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      'Geofence will be visible on map',
                      style: AppTextStyles.metaWithColor(context),
                    ),
                  ],
                ),
              ),
              Switch(value: isActive, onChanged: onActiveChanged),
            ],
          ),
        ),
      ],
    );
  }
}
