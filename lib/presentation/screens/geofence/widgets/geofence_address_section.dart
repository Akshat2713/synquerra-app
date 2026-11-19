import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../themes/app_text_styles.dart';
import '../../../themes/colors.dart';
import '../../../themes/app_tokens.dart';
import '../../../utils/app_icons.dart';
import '../../../widgets/app_surfaces.dart';

/// Holds controllers + null-safe getters for optional geofence address fields.
/// Reusable wherever a geofence address needs to be collected/edited.
class GeofenceAddressFields {
  final addressController = TextEditingController();
  final localityController = TextEditingController();
  final blockController = TextEditingController();
  final districtController = TextEditingController();
  final stateController = TextEditingController();
  final postcodeController = TextEditingController();
  final countryController = TextEditingController();
  final landmarkController = TextEditingController();

  GeofenceAddressFields({
    String? address,
    String? locality,
    String? block,
    String? district,
    String? state,
    String? postcode,
    String? country,
    String? landmark,
  }) {
    addressController.text = address ?? '';
    localityController.text = locality ?? '';
    blockController.text = block ?? '';
    districtController.text = district ?? '';
    stateController.text = state ?? '';
    postcodeController.text = postcode ?? '';
    countryController.text = country ?? '';
    landmarkController.text = landmark ?? '';
  }

  String? _n(String v) => v.trim().isEmpty ? null : v.trim();

  String? get address => _n(addressController.text);
  String? get locality => _n(localityController.text);
  String? get block => _n(blockController.text);
  String? get district => _n(districtController.text);
  String? get state => _n(stateController.text);
  String? get postcode => _n(postcodeController.text);
  String? get country => _n(countryController.text);
  String? get landmark => _n(landmarkController.text);

  void dispose() {
    addressController.dispose();
    localityController.dispose();
    blockController.dispose();
    districtController.dispose();
    stateController.dispose();
    postcodeController.dispose();
    countryController.dispose();
    landmarkController.dispose();
  }
}

/// Collapsible "Address (optional)" form section.
/// Collapsible "Address (optional)" form section.
/// "Address (optional)" fields, meant to sit inside another card.
/// Collapsible "Address (optional)" fields, meant to sit inside another card.
/// Collapsed by default. Controllers live in [GeofenceAddressFields], so
/// collapsing never loses what the user typed.
class GeofenceAddressSection extends StatefulWidget {
  final GeofenceAddressFields fields;
  final bool initiallyExpanded;

  const GeofenceAddressSection({
    super.key,
    required this.fields,
    this.initiallyExpanded = false,
  });

  @override
  State<GeofenceAddressSection> createState() => _GeofenceAddressSectionState();
}

class _GeofenceAddressSectionState extends State<GeofenceAddressSection> {
  late bool _expanded = widget.initiallyExpanded;

  void _toggle() {
    HapticFeedback.selectionClick();
    setState(() => _expanded = !_expanded);
  }

  @override
  Widget build(BuildContext context) {
    final f = widget.fields;
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : AppMotion.base;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          button: true,
          expanded: _expanded,
          child: InsetRow(
            onTap: _toggle,
            child: Row(
              spacing: AppSpacing.sm,
              children: [
                Icon(
                  AppIcons.address,
                  size: AppSize.iconSm,
                  color: AppColors.iconSecondary(context),
                ),
                Expanded(
                  child: Text(
                    'Address (optional)',
                    style: AppTextStyles.bodyWithColor(
                      context,
                      color: AppColors.textPrimary(context),
                    ).copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                AnimatedRotation(
                  turns: _expanded ? 0.5 : 0,
                  duration: duration,
                  curve: AppMotion.curve,
                  child: Icon(
                    AppIcons.keyboardArrowDown,
                    size: AppSize.icon,
                    color: AppColors.primary(context),
                  ),
                ),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: duration,
          curve: AppMotion.curve,
          alignment: Alignment.topCenter,
          child: _expanded
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: AppSpacing.smd,
                  children: [
                    _field(f.addressController, 'Address'),
                    _row(
                      _field(f.blockController, 'Block / House No.'),
                      _field(f.localityController, 'Locality'),
                    ),
                    _row(
                      _field(f.districtController, 'District'),
                      _field(f.stateController, 'State'),
                    ),
                    _row(
                      _field(f.postcodeController, 'Postcode'),
                      _field(f.countryController, 'Country'),
                    ),
                    _field(f.landmarkController, 'Landmark'),
                  ],
                )
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }

  Widget _row(Widget a, Widget b) => Row(
    spacing: AppSpacing.smd,
    children: [
      Expanded(child: a),
      Expanded(child: b),
    ],
  );

  Widget _field(TextEditingController c, String label) => TextFormField(
    controller: c,
    decoration: InputDecoration(labelText: label),
  );
}
