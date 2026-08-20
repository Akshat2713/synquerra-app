// lib/presentation/screens/geofence/add_geofence_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/utils/app_logger.dart';
import '../../../domain/entities/geofence/geofence_entity.dart';
import '../../app/app_router.dart';
import '../../blocs/geofence/geofence_bloc.dart';
import '../../utils/colour_util.dart' as colour_utils;
import 'utils/map_bounds_util.dart';
import 'widgets/empty_coordinates_placeholder.dart';
import 'widgets/geofence_active_toggle.dart';
import 'widgets/geofence_address_section.dart';
import 'widgets/geofence_color_picker.dart';
import 'widgets/geofence_map_preview.dart';
import 'widgets/geofence_name_input.dart';

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
        : const Color(0xFF2196F3);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressFields.dispose();
    super.dispose();
  }

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
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_coordinates == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please pick geofence area on map.')),
      );
      return;
    }

    if (_isEditing) {
      context.read<GeofenceBloc>().add(
        GeofenceEdit(
          deviceId: widget.deviceId,
          geofenceId: widget.existing!.geofenceId,
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
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Geofence' : 'New Geofence'),
      ),
      body: BlocListener<GeofenceBloc, GeofenceState>(
        listener: (context, state) {
          if (state is GeofenceCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '${state.geofence.geofenceName} created successfully.',
                ),
                backgroundColor: colors.primary,
              ),
            );
            Navigator.pop(context);
          } else if (state is GeofenceEdited) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '${state.geofence.geofenceName} updated successfully.',
                ),
                backgroundColor: colors.primary,
              ),
            );
            Navigator.pop(context);
          } else if (state is GeofenceOperationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: colors.error,
              ),
            );
          }
        },
        child: BlocBuilder<GeofenceBloc, GeofenceState>(
          builder: (context, state) {
            final isLoading = state is GeofenceOperationLoading;
            return Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  GeofenceNameInput(controller: _nameController),
                  const SizedBox(height: 24),
                  GeofenceActiveToggle(
                    isActive: _isActive,
                    onChanged: (v) => setState(() => _isActive = v),
                  ),
                  const SizedBox(height: 24),
                  GeofenceAddressSection(fields: _addressFields),
                  const SizedBox(height: 24),
                  GeofenceColorPickerTile(
                    selectedColor: _selectedColor,
                    onColorChanged: (c) => setState(() => _selectedColor = c),
                  ),
                  const SizedBox(height: 24),
                  Text('Geofence Area', style: textTheme.labelLarge),
                  const SizedBox(height: 8),
                  _coordinates == null
                      ? EmptyCoordinatesPlaceholder(onTap: _openMapPicker)
                      : GeofenceMapPreview(
                          coordinates: _coordinates!,
                          color: _selectedColor,
                          onTap: _openMapPicker,
                        ),
                  const SizedBox(height: 32),
                  FilledButton(
                    onPressed: isLoading ? null : _onSave,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator.adaptive(
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            _isEditing ? 'Update Geofence' : 'Save Geofence',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
