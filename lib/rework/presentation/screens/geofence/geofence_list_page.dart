import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import '../../../domain/entities/geofence/geofence_entity.dart';
import '../../blocs/geofence/geofence_bloc.dart';
import 'add_geofence_page.dart';
import 'geofence_preview_page.dart';
import 'widgets/geofence_list_tile.dart';

class GeofenceListPage extends StatefulWidget {
  final String imei;
  final LatLng initialCenter;

  const GeofenceListPage({
    super.key,
    required this.imei,
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
    // Always refresh when page opens
    context.read<GeofenceBloc>().add(GeofenceLoad(widget.imei));
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
                  imei: widget.imei,
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

  void _openAddPage() {
    final bloc = context.read<GeofenceBloc>(); // grab current instance
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: bloc, // reuse same instance
          child: AddGeofencePage(
            imei: widget.imei,
            initialCenter: widget.initialCenter,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

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
                backgroundColor: colors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          // ── Loading ──────────────────────────────
          if (state is GeofenceLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // ── Operation in progress ────────────────
          if (state is GeofenceOperationLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // ── Error ────────────────────────────────
          if (state is GeofenceError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, color: colors.error, size: 48),
                  const SizedBox(height: 12),
                  Text(state.message, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => context.read<GeofenceBloc>().add(
                      GeofenceLoad(widget.imei),
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          // ── Loaded ───────────────────────────────
          final geofences = state is GeofenceLoaded
              ? state.geofences
              : <GeofenceEntity>[];
          final filtered = _filtered(geofences);

          return Column(
            children: [
              // ── Search bar ─────────────────────
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

              // ── Count label ────────────────────
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
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              // ── List ───────────────────────────
              Expanded(
                child: filtered.isEmpty
                    ? _EmptyState(
                        isSearching: _query.isNotEmpty,
                        onAdd: _openAddPage,
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final g = filtered[index];
                          return GeofenceListTile(
                            geofence: g,
                            onTap: () => _onTileTab(g),
                            onEdit: () {
                              // TODO: navigate to edit page
                            },
                            onDelete: () => _confirmDelete(context, g),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Navigates back to the map and moves camera to geofence center.
  void _onTileTab(GeofenceEntity geofence) {
    if (geofence.coordinates.isEmpty) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GeofencePreviewPage(geofence: geofence),
      ),
    );
  }
}

// ── Empty state ────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final bool isSearching;
  final VoidCallback onAdd;

  const _EmptyState({required this.isSearching, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSearching ? Icons.search_off_rounded : Icons.fence_rounded,
            size: 56,
            color: colors.onSurfaceVariant.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 12),
          Text(
            isSearching
                ? 'No geofences match your search.'
                : 'No geofences yet.',
            style: TextStyle(color: colors.onSurfaceVariant),
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
