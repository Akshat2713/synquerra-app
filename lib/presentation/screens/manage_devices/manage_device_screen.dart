import 'package:flutter/material.dart';
import '../../../../domain/entities/device/device_entity.dart';
import '../../../../domain/entities/relationship/relationship_entity.dart';
import 'manage_device_card.dart';

class ManageDevicesScreen extends StatefulWidget {
  final List<DeviceEntity> devices;
  final List<RelationshipEntity> relationships;
  final String currentUserId;
  final String currentUserFullName;
  final Future<void> Function()? onRefresh;
  final Function(String deviceId, String personId, String associationType)?
  onAssignDevice;
  final Function(String deviceId, String associationType)? onUnassignDevice;

  const ManageDevicesScreen({
    super.key,
    this.devices = const [],
    this.relationships = const [],
    this.currentUserId = '',
    this.currentUserFullName = '',
    this.onRefresh,
    this.onAssignDevice,
    this.onUnassignDevice,
  });

  @override
  State<ManageDevicesScreen> createState() => _ManageDevicesScreenState();
}

class _ManageDevicesScreenState extends State<ManageDevicesScreen> {
  String? _processingDeviceId;

  List<DeviceEntity> get _ownedDevices => widget.devices
      .where((d) => d.relationship == 'owned' || d.relationship == 'both')
      .toList();

  List<DeviceEntity> get _unassignedDevices =>
      _ownedDevices.where((d) => d.carrier == null).toList();

  List<DeviceEntity> get _assignedDevices =>
      _ownedDevices.where((d) => d.carrier != null).toList();

  Future<void> _handleAssign(
    String deviceId,
    String personId,
    String associationType,
  ) async {
    if (widget.onAssignDevice == null) return;
    setState(() => _processingDeviceId = deviceId);
    await widget.onAssignDevice!(deviceId, personId, associationType);
    if (mounted) setState(() => _processingDeviceId = null);
  }

  Future<void> _handleUnassign(String deviceId, String associationType) async {
    if (widget.onUnassignDevice == null) return;
    setState(() => _processingDeviceId = deviceId);
    await widget.onUnassignDevice!(deviceId, associationType);
    if (mounted) setState(() => _processingDeviceId = null);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(title: const Text('Manage Devices'), centerTitle: false),
      body: RefreshIndicator(
        onRefresh: widget.onRefresh ?? () async {},
        color: colors.primary,
        child: _ownedDevices.isEmpty
            ? Center(
                child: Text(
                  'No owned devices found.',
                  style: TextStyle(color: colors.onSurfaceVariant),
                ),
              )
            : CustomScrollView(
                slivers: [
                  // SECTION 1: Unassigned Devices
                  _buildSectionHeader(
                    context,
                    title: 'Unassigned Devices',
                    count: _unassignedDevices.length,
                    color: colors.error,
                  ),
                  if (_unassignedDevices.isEmpty)
                    _buildEmptyPlaceholder('No unassigned devices')
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final device = _unassignedDevices[index];
                        return ManageDeviceCard(
                          device: device,
                          currentUserFullName: widget.currentUserFullName,
                          currentUserId: widget.currentUserId,
                          relationships: widget.relationships,
                          isProcessing: _processingDeviceId == device.id,
                          onAssign: (personId, associationType) =>
                              _handleAssign(
                                device.id,
                                personId,
                                associationType,
                              ),
                          onUnassign: (associationType) =>
                              _handleUnassign(device.id, associationType),
                        );
                      }, childCount: _unassignedDevices.length),
                    ),

                  // SECTION 2: Assigned Devices
                  _buildSectionHeader(
                    context,
                    title: 'Assigned Devices',
                    count: _assignedDevices.length,
                    color: colors.primary,
                  ),
                  if (_assignedDevices.isEmpty)
                    _buildEmptyPlaceholder('No assigned devices')
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final device = _assignedDevices[index];
                        return ManageDeviceCard(
                          device: device,
                          currentUserFullName: widget.currentUserFullName,
                          currentUserId: widget.currentUserId,
                          relationships: widget.relationships,
                          isProcessing: _processingDeviceId == device.id,
                          onAssign: (personId, associationType) =>
                              _handleAssign(
                                device.id,
                                personId,
                                associationType,
                              ),
                          onUnassign: (associationType) =>
                              _handleUnassign(device.id, associationType),
                        );
                      }, childCount: _assignedDevices.length),
                    ),

                  const SliverToBoxAdapter(child: SizedBox(height: 32)),
                ],
              ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    required int count,
    required Color color,
  }) {
    final colors = Theme.of(context).colorScheme;
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Row(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '($count)',
              style: TextStyle(fontSize: 13, color: colors.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyPlaceholder(String message) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
