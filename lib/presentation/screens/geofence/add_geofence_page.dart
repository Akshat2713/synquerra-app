import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/utils/app_logger.dart';
import '../../../domain/entities/geofence/geofence_entity.dart';
import '../../app/app_router.dart';
import '../../blocs/geofence/geofence_bloc.dart';
import '../../themes/app_tokens.dart';
import '../../themes/colors.dart';
import '../../utils/colour_util.dart' as colour_utils;
import '../../widgets/app_button.dart';
import '../../widgets/app_motion_widgets.dart';
import '../../widgets/app_overlays.dart';
import 'utils/map_bounds_util.dart';
import 'widgets/geofence_address_section.dart';
import 'widgets/geofence_area_card.dart';
import 'widgets/geofence_details_card.dart';

class AddGeofencePage extends StatefulWidget {
  final String deviceId;
  final LatLng initialCenter;
  final GeofenceEntity? existing;

  const AddGeofencePage({
    super.key,
    required this.deviceId,
    required this.initialCenter,
    this.existing,
  });

  @override
  State<AddGeofencePage> createState() => _AddGeofencePageState();
}

class _AddGeofencePageState extends State<AddGeofencePage> {
  final _formKey = GlobalKey<FormState>();
  late final _nameController = TextEditingController(
    text: widget.existing?.geofenceName ?? '',
  );
  late bool _isActive = widget.existing?.isActive ?? true;
  late Color _selectedColor;
  List<Coordinate>? _coordinates;
  bool get _isEditing => widget.existing != null;
  late final _addressFields = GeofenceAddressFields(
    address: widget.existing?.address,
    locality: widget.existing?.locality,
    block: widget.existing?.block,
    district: widget.existing?.district,
    state: widget.existing?.state,
    postcode: widget.existing?.postcode,
    country: widget.existing?.country,
    landmark: widget.existing?.landmark,
  );

  @override
  void initState() {
    super.initState();
    _coordinates = widget.existing?.coordinates;
    _selectedColor = widget.existing != null
        ? colour_utils.colorFromHex(widget.existing!.geofenceColor)
        : AppColors.info;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressFields.dispose();
    super.dispose();
  }

  // TODO(logic): route name should come from AppRoutes.
  Future<void> _openMapPicker() async {
    final existingPoints = _coordinates
        ?.map((c) => LatLng(c.lat, c.lng))
        .toList();
    final center = centroidOf(existingPoints ?? []) ?? widget.initialCenter;

    final result = await Navigator.pushNamed<List<Coordinate>>(
      context,
      '/geofence-map-picker',
      arguments: GeofenceMapPickerArgs(
        initialCenter: center,
        initialPoints: _coordinates,
      ),
    );
    if (result != null) {
      setState(() => _coordinates = result);
      AppLogger.d('AddGeofencePage', 'Got ${result.length} coordinates');
    }
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;

    if (_coordinates == null) {
      AppSnackBar.info(context, 'Please pick geofence area on map.');
      return;
    }

    if (_isEditing) {
      context.read<GeofenceBloc>().add(
        GeofenceEdit(
          deviceId: widget.deviceId,
          id: widget.existing!.id,
          name: _nameController.text.trim(),
          isActive: _isActive,
          coordinates: _coordinates!,
          color: colour_utils.hexFromColor(_selectedColor),
          geofenceNumber: widget.existing!.geofenceNumber,
          locality: _addressFields.locality,
          block: _addressFields.block,
          district: _addressFields.district,
          state: _addressFields.state,
          postcode: _addressFields.postcode,
          country: _addressFields.country,
          landmark: _addressFields.landmark,
          address: _addressFields.address,
        ),
      );
    } else {
      context.read<GeofenceBloc>().add(
        GeofenceCreate(
          deviceId: widget.deviceId,
          name: _nameController.text.trim(),
          isActive: _isActive,
          coordinates: _coordinates!,
          color: colour_utils.hexFromColor(_selectedColor),
          locality: _addressFields.locality,
          block: _addressFields.block,
          district: _addressFields.district,
          state: _addressFields.state,
          postcode: _addressFields.postcode,
          country: _addressFields.country,
          landmark: _addressFields.landmark,
          address: _addressFields.address,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Geofence' : 'New Geofence'),
      ),
      body: BlocConsumer<GeofenceBloc, GeofenceState>(
        listener: (context, state) {
          if (state is GeofenceCreated) {
            AppSnackBar.success(
              context,
              '${state.geofence.geofenceName} created successfully.',
            );
            Navigator.pop(context);
          } else if (state is GeofenceEdited) {
            AppSnackBar.success(
              context,
              '${state.geofence.geofenceName} updated successfully.',
            );
            Navigator.pop(context);
          } else if (state is GeofenceOperationError) {
            AppSnackBar.error(context, state.message);
          }
        },
        builder: (context, state) {
          final isLoading = state is GeofenceOperationLoading;

          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: AppSpacing.mdAll,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: AppSpacing.md,
                children: [
                  GeofenceDetailsCard(
                    controller: _nameController,
                    addressFields: _addressFields,
                    isActive: _isActive,
                    onActiveChanged: (v) => setState(() => _isActive = v),
                  ).entrance(context, index: 0),
                  GeofenceAreaCard(
                    coordinates: _coordinates,
                    color: _selectedColor,
                    onColorChanged: (c) => setState(() => _selectedColor = c),
                    onOpenMap: _openMapPicker,
                  ).entrance(context, index: 1),
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.sm),
                    child: AppButton(
                      label: _isEditing ? 'Update Geofence' : 'Save Geofence',
                      isLoading: isLoading,
                      onPressed: _onSave,
                    ),
                  ).entrance(context, index: 2),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
