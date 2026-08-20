import 'package:flutter/material.dart';

import '../../../themes/colors.dart';

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
class GeofenceAddressSection extends StatelessWidget {
  final GeofenceAddressFields fields;
  const GeofenceAddressSection({super.key, required this.fields});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.outlineVariant(context)),
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.antiAlias,
        child: ExpansionTile(
          title: const Text('Address (optional)'),
          leading: const Icon(Icons.location_on_outlined),
          tilePadding: const EdgeInsets.symmetric(horizontal: 16),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          children: [
            _field(fields.addressController, 'Address'),
            const SizedBox(height: 12),
            _row(
              _field(fields.blockController, 'Block / House No.'),
              _field(fields.localityController, 'Locality'),
            ),
            const SizedBox(height: 12),
            _row(
              _field(fields.districtController, 'District'),
              _field(fields.stateController, 'State'),
            ),
            const SizedBox(height: 12),
            _row(
              _field(fields.postcodeController, 'Postcode'),
              _field(fields.countryController, 'Country'),
            ),
            const SizedBox(height: 12),
            _field(fields.landmarkController, 'Landmark'),
          ],
        ),
      ),
    );
  }

  Widget _row(Widget a, Widget b) => Row(
    children: [
      Expanded(child: a),
      const SizedBox(width: 12),
      Expanded(child: b),
    ],
  );

  Widget _field(TextEditingController c, String label) => TextFormField(
    controller: c,
    decoration: InputDecoration(
      labelText: label,
      isDense: true,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    ),
  );
}
