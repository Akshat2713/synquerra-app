// lib/presentation/screens/geofence/geofence_list_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import '../../../domain/entities/geofence/geofence_entity.dart';
import '../../app/app_router.dart';
import '../../blocs/geofence/geofence_bloc.dart';
import '../../themes/colors.dart';
import '../../widgets/async_state_view.dart';
import 'widgets/geofence_list_tile.dart';

class GeofenceListPage extends StatefulWidget {
  final String deviceId;
  final LatLng initialCenter;

  const GeofenceListPage({
    super.key,
    required this.deviceId,
    required this.initialCenter,
  });

  @override
  State<GeofenceListPage> createState() => _GeofenceListPageState();
}

class _GeofenceListPageState extends State<GeofenceListPage> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    context.read<GeofenceBloc>().add(GeofenceLoad(widget.deviceId));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<GeofenceEntity> _filtered(List<GeofenceEntity> all) {
    if (_query.isEmpty) return all;
    return all
        .where(
          (g) => g.geofenceName.toLowerCase().contains(_query.toLowerCase()),
        )
        .toList();
  }

  void _confirmDelete(BuildContext context, GeofenceEntity geofence) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Geofence'),
        content: Text(
          'Are you sure you want to delete "${geofence.geofenceName}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () {
              Navigator.pop(context);
              context.read<GeofenceBloc>().add(
                GeofenceDelete(
                  deviceId: widget.deviceId,
                  geofenceId: geofence.geofenceId,
                ),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _openAddPage({GeofenceEntity? existing}) {
    AppRouter.pushAddGeofence(
      context,
      bloc: context.read<GeofenceBloc>(),
      deviceId: widget.deviceId,
      initialCenter: widget.initialCenter,
      existing: existing,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Geofences')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddPage,
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Geofence'),
      ),
      body: BlocConsumer<GeofenceBloc, GeofenceState>(
        listener: (context, state) {
          if (state is GeofenceDeleted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Geofence deleted.')));
          } else if (state is GeofenceOperationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.danger,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is GeofenceLoading;
          final errorMessage = state is GeofenceError ? state.message : null;
          final geofences = state is GeofenceLoaded
              ? state.geofences
              : <GeofenceEntity>[];
          final filtered = _filtered(geofences);

          return AsyncStateView(
            isLoading: isLoading,
            errorMessage: errorMessage,
            onRetry: () =>
                context.read<GeofenceBloc>().add(GeofenceLoad(widget.deviceId)),
            builder: () => Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (v) => setState(() => _query = v),
                    decoration: InputDecoration(
                      hintText: 'Search geofences...',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _query.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _query = '');
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  child: Row(
                    children: [
                      Text(
                        '${filtered.length} geofence${filtered.length == 1 ? '' : 's'}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary(context),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: filtered.isEmpty
                      ? _EmptyState(
                          isSearching: _query.isNotEmpty,
                          onAdd: _openAddPage,
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final g = filtered[index];
                            return GeofenceListTile(
                              geofence: g,
                              onTap: () => _onTileTab(g),
                              onEdit: () => _openAddPage(existing: g),
                              onDelete: () => _confirmDelete(context, g),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _onTileTab(GeofenceEntity geofence) {
    if (geofence.coordinates.isEmpty) return;
    Navigator.pushNamed(
      context,
      AppRoutes.geofencePreview,
      arguments: GeofencePreviewArgs(geofence: geofence),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool isSearching;
  final VoidCallback onAdd;

  const _EmptyState({required this.isSearching, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSearching ? Icons.search_off_rounded : Icons.fence_rounded,
            size: 56,
            color: AppColors.textSecondary(context).withValues(alpha: 0.4),
          ),
          const SizedBox(height: 12),
          Text(
            isSearching
                ? 'No geofences match your search.'
                : 'No geofences yet.',
            style: TextStyle(color: AppColors.textSecondary(context)),
          ),
          if (!isSearching) ...[
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_rounded),
              label: const Text('New Geofence'),
            ),
          ],
        ],
      ),
    );
  }
}
