import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import '../../../domain/entities/geofence/geofence_entity.dart';
import '../../blocs/geofence/geofence_bloc.dart';
import 'geofence_map_picker_page.dart';

class AddGeofencePage extends StatefulWidget {
  final String imei;
  final LatLng initialCenter;

  const AddGeofencePage({
    super.key,
    required this.imei,
    required this.initialCenter,
  });

  @override
  State<AddGeofencePage> createState() => _AddGeofencePageState();
}

class _AddGeofencePageState extends State<AddGeofencePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  bool _isActive = true;
  List<Coordinate>? _coordinates; // null = not picked yet

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _openMapPicker() async {
    final result = await Navigator.push<List<Coordinate>>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            GeofenceMapPickerPage(initialCenter: widget.initialCenter),
      ),
    );
    if (result != null) {
      setState(() => _coordinates = result);
      debugPrint('[AddGeofencePage] Got ${result.length} coordinates');
    }
  }

  void _onSave() {
    debugPrint('[AddGeofencePage] _onSave called');
    debugPrint(
      '[AddGeofencePage] form valid: ${_formKey.currentState?.validate()}',
    );
    debugPrint('[AddGeofencePage] coordinates: $_coordinates');
    debugPrint('[AddGeofencePage] name: ${_nameController.text.trim()}');
    debugPrint('[AddGeofencePage] isActive: $_isActive');

    if (!_formKey.currentState!.validate()) {
      debugPrint('[AddGeofencePage] Form validation failed');
      return;
    }
    if (_coordinates == null) {
      debugPrint('[AddGeofencePage] Coordinates are null');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please pick geofence area on map.')),
      );
      return;
    }

    debugPrint('[AddGeofencePage] Dispatching GeofenceCreate event');
    context.read<GeofenceBloc>().add(
      GeofenceCreate(
        imei: widget.imei,
        name: _nameController.text.trim(),
        isActive: _isActive,
        coordinates: _coordinates!,
      ),
    );
    debugPrint('[AddGeofencePage] GeofenceCreate event dispatched');
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('New Geofence')),
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
                  // ── Name ────────────────────────────
                  Text('Geofence Name', style: textTheme.labelLarge),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      hintText: 'e.g. School Zone',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Name is required'
                        : null,
                  ),
                  const SizedBox(height: 24),

                  // ── Active toggle ────────────────────
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: colors.outlineVariant),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.toggle_on_outlined, color: colors.primary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Active',
                                style: textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                'Geofence will be visible on map',
                                style: textTheme.bodySmall?.copyWith(
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _isActive,
                          onChanged: (v) => setState(() => _isActive = v),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Coordinates ──────────────────────
                  Text('Coordinates', style: textTheme.labelLarge),
                  const SizedBox(height: 8),
                  _coordinates == null
                      ? _EmptyCoordinatesPlaceholder(onTap: _openMapPicker)
                      : _CoordinatesList(
                          coordinates: _coordinates!,
                          onReset: _openMapPicker,
                        ),
                  const SizedBox(height: 32),

                  // ── Save button ──────────────────────
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
                        : const Text(
                            'Save Geofence',
                            style: TextStyle(fontWeight: FontWeight.w600),
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

// ── Sub-widgets ────────────────────────────────────────────────────────────

class _EmptyCoordinatesPlaceholder extends StatelessWidget {
  final VoidCallback onTap;
  const _EmptyCoordinatesPlaceholder({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 28),
        decoration: BoxDecoration(
          border: Border.all(
            color: colors.primary.withValues(alpha: 0.4),
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(12),
          color: colors.primaryContainer.withValues(alpha: 0.15),
        ),
        child: Column(
          children: [
            Icon(Icons.map_outlined, size: 36, color: colors.primary),
            const SizedBox(height: 8),
            Text(
              'Tap to draw on map',
              style: TextStyle(
                color: colors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Place exactly 5 points to define the zone',
              style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _CoordinatesList extends StatelessWidget {
  final List<Coordinate> coordinates;
  final VoidCallback onReset;

  const _CoordinatesList({required this.coordinates, required this.onReset});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    // Show only first 5 — last is closing point (duplicate of first)
    final display = coordinates.take(5).toList();

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: colors.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          ...display.asMap().entries.map((e) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: colors.primaryContainer,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${e.key + 1}',
                            style: textTheme.labelSmall?.copyWith(
                              color: colors.onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '${e.value.lat.toStringAsFixed(6)},  ${e.value.lng.toStringAsFixed(6)}',
                          style: textTheme.bodySmall?.copyWith(
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (e.key < display.length - 1)
                  Divider(height: 1, color: colors.outlineVariant),
              ],
            );
          }),
          // ── Redraw button ──────────────────────
          Divider(height: 1, color: colors.outlineVariant),
          TextButton.icon(
            onPressed: onReset,
            icon: const Icon(Icons.edit_location_alt_outlined, size: 18),
            label: const Text('Redraw on map'),
          ),
        ],
      ),
    );
  }
}
