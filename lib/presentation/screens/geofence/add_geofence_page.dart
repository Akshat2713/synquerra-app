import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/utils/app_logger.dart';
import '../../../domain/entities/geofence/geofence_entity.dart';
import '../../blocs/geofence/geofence_bloc.dart';
import '../../utils/colour_util.dart' as colour_utils;
import 'geofence_map_picker_page.dart';
import 'widgets/coordinates_list.dart';
import 'widgets/empty_coordinates_placeholder.dart';
import 'widgets/geofence_active_toggle.dart';
import 'widgets/geofence_color_picker.dart';
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
    super.dispose();
  }

  Future<void> _openMapPicker() async {
    final result = await Navigator.push<List<Coordinate>>(
      context,
      MaterialPageRoute(
        builder: (_) => GeofenceMapPickerPage(
          initialCenter: widget.initialCenter,
          initialPoints: _coordinates,
        ),
      ),
    );
    if (result != null) {
      setState(() => _coordinates = result);
      AppLogger.d('AddGeofencePage', 'Got ${result.length} coordinates');
    }
  }

  void _onSave() {
    AppLogger.d('AddGeofencePage', '_onSave called');
    AppLogger.d(
      'AddGeofencePage',
      'form valid: ${_formKey.currentState?.validate()}',
    );
    AppLogger.d('AddGeofencePage', 'coordinates: $_coordinates');
    AppLogger.d('AddGeofencePage', 'name: ${_nameController.text.trim()}');
    AppLogger.d('AddGeofencePage', 'isActive: $_isActive');
    AppLogger.d('AddGeofencePage', 'color: $_selectedColor');

    if (!_formKey.currentState!.validate()) {
      AppLogger.d('AddGeofencePage', 'Form validation failed');
      return;
    }
    if (_coordinates == null) {
      AppLogger.d('AddGeofencePage', 'Coordinates are null');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please pick geofence area on map.')),
      );
      return;
    }

    if (_isEditing) {
      AppLogger.d('AddGeofencePage', 'Dispatching GeofenceEdit event');
      context.read<GeofenceBloc>().add(
        GeofenceEdit(
          deviceId: widget.deviceId,
          geofenceId: widget.existing!.geofenceId,
          name: _nameController.text.trim(),
          isActive: _isActive,
          coordinates: _coordinates!,
          color: colour_utils.hexFromColor(_selectedColor),
          geofenceNumber: widget.existing!.geofenceNumber,
          entryAlertDelay: widget.existing!.entryAlertDelay,
          exitAlertDelay: widget.existing!.exitAlertDelay,
        ),
      );
    } else {
      AppLogger.d('AddGeofencePage', 'Dispatching GeofenceCreate event');
      context.read<GeofenceBloc>().add(
        GeofenceCreate(
          deviceId: widget.deviceId,
          name: _nameController.text.trim(),
          isActive: _isActive,
          coordinates: _coordinates!,
          color: colour_utils.hexFromColor(_selectedColor),
        ),
      );
    }
    AppLogger.d('AddGeofencePage', 'event dispatched');
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
                  GeofenceColorPickerTile(
                    selectedColor: _selectedColor,
                    onColorChanged: (c) => setState(() => _selectedColor = c),
                  ),
                  const SizedBox(height: 24),
                  Text('Coordinates', style: textTheme.labelLarge),
                  const SizedBox(height: 8),
                  _coordinates == null
                      ? EmptyCoordinatesPlaceholder(onTap: _openMapPicker)
                      : CoordinatesList(
                          coordinates: _coordinates!,
                          onReset: _openMapPicker,
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
                            child: CircularProgressIndicator(strokeWidth: 2),
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
