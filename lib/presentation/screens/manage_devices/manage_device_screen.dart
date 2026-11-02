import 'package:flutter/material.dart';
import '../../../../domain/entities/device/device_entity.dart';
import '../../../../domain/entities/relationship/relationship_entity.dart';
import '../../themes/app_text_styles.dart';
import '../../themes/app_tokens.dart';
import '../../themes/colors.dart';
import '../../utils/app_icons.dart';
import '../../widgets/app_empty_state.dart';
import '../../widgets/app_motion_widgets.dart';
import '../../widgets/app_surfaces.dart';
import 'widgets/manage_device_card.dart';

class ManageDevicesScreen extends StatefulWidget {
  final List<DeviceEntity> devices;
  final List<RelationshipEntity> relationships;
  final String currentUserId;
  final String currentUserFullName;
  final Future<void> Function()? onRefresh;
  final Function(String deviceId, String personId, String associationType)?
  onAssignDevice;
  final Function(String deviceId, String personId, String associationType)?
  onUnassignDevice;
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
  // TODO(logic): ManageDevicesLoaded already exposes processingDeviceId.
  // Read it from the bloc instead of tracking it here.
  String? _processingDeviceId;

  List<DeviceEntity> get _unassignedDevices => widget.devices.unassignedDevices;
  List<DeviceEntity> get _assignedDevices => widget.devices.assignedDevices;
  List<DeviceEntity> get _ownedDevices => widget.devices.ownedDevices;

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

  Future<void> _handleUnassign(
    String deviceId,
    String personId,
    String associationType,
  ) async {
    if (widget.onUnassignDevice == null) return;
    setState(() => _processingDeviceId = deviceId);
    await widget.onUnassignDevice!(deviceId, personId, associationType);
    if (mounted) setState(() => _processingDeviceId = null);
  }

  Widget _card(DeviceEntity device) => ManageDeviceCard(
    device: device,
    currentUserFullName: widget.currentUserFullName,
    currentUserId: widget.currentUserId,
    relationships: widget.relationships,
    isProcessing: _processingDeviceId == device.id,
    onAssign: (personId, type) => _handleAssign(device.id, personId, type),
    onUnassign: (personId, type) => _handleUnassign(device.id, personId, type),
  );

  @override
  Widget build(BuildContext context) {
    final unassigned = _unassignedDevices;
    final assigned = _assignedDevices;
    final owned = _ownedDevices;

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Devices')),
      body: RefreshIndicator(
        onRefresh: widget.onRefresh ?? () async {},
        child: owned.isEmpty
            ? LayoutBuilder(
                builder: (context, box) => SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: box.maxHeight),
                    child: const Center(
                      child: AppEmptyState(
                        icon: AppIcons.devices,
                        title: 'No owned devices found',
                        message: 'Devices you own will show up here.',
                      ),
                    ),
                  ),
                ),
              )
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.xl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: AppSpacing.lg,
                  children: [
                    _SummaryHero(
                      total: owned.length,
                      assigned: assigned.length,
                      unassigned: unassigned.length,
                    ).entrance(context, index: 0),
                    _Section(
                      title: 'Needs assignment',
                      count: unassigned.length,
                      dotColor: AppColors.warning,
                      pillBackground: AppColors.warningContainer,
                      emptyMessage: 'Every device has a carrier',
                      children: [for (final d in unassigned) _card(d)],
                    ).entrance(context, index: 1),
                    _Section(
                      title: 'Assigned',
                      count: assigned.length,
                      dotColor: AppColors.success,
                      pillBackground: AppColors.successContainer,
                      emptyMessage: 'No assigned devices yet',
                      children: [for (final d in assigned) _card(d)],
                    ).entrance(context, index: 2),
                  ],
                ),
              ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────── hero

class _SummaryHero extends StatelessWidget {
  final int total;
  final int assigned;
  final int unassigned;
  const _SummaryHero({
    required this.total,
    required this.assigned,
    required this.unassigned,
  });

  @override
  Widget build(BuildContext context) {
    final onPrimary = AppColors.onPrimary(context);
    final pillBg = AppAlpha.withAlpha(onPrimary, AppAlpha.fill);

    return Container(
      padding: AppSpacing.mdAll,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient(context),
        borderRadius: AppRadius.lgAll,
        boxShadow: AppShadow.glow(AppColors.primary(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpacing.md,
        children: [
          Row(
            spacing: AppSpacing.md,
            children: [
              IconTile(
                icon: AppIcons.devices,
                background: pillBg,
                foreground: onPrimary,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: AppSpacing.xs,
                  children: [
                    Text(
                      total == 1 ? '1 device' : '$total devices',
                      style: AppTextStyles.titleWithColor(
                        context,
                        color: onPrimary,
                      ),
                    ),
                    Text(
                      unassigned == 0
                          ? 'All devices have a carrier'
                          : (unassigned == 1
                                ? '1 device needs a carrier'
                                : '$unassigned devices need a carrier'),
                      style: AppTextStyles.metaWithColor(
                        context,
                        color: AppAlpha.withAlpha(onPrimary, AppAlpha.strong),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              InfoPill(
                label: '$assigned assigned',
                icon: AppIcons.activeCheck,
                background: pillBg,
                foreground: onPrimary,
              ),
              InfoPill(
                label: '$unassigned unassigned',
                icon: AppIcons.info,
                background: pillBg,
                foreground: onPrimary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────── section

class _Section extends StatelessWidget {
  final String title;
  final int count;
  final Color dotColor;
  final Color pillBackground;
  final String emptyMessage;
  final List<Widget> children;

  const _Section({
    required this.title,
    required this.count,
    required this.dotColor,
    required this.pillBackground,
    required this.emptyMessage,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSpacing.smd,
      children: [
        Padding(
          padding: AppSpacing.xsHorizontal,
          child: Row(
            spacing: AppSpacing.sm,
            children: [
              Text(title, style: AppTextStyles.sectionWithColor(context)),
              InfoPill(
                label: '$count',
                dotColor: dotColor,
                background: pillBackground,
                foreground: AppColors.textPrimary(context),
              ),
            ],
          ),
        ),
        if (children.isEmpty)
          InsetRow(
            child: Center(
              child: Text(
                emptyMessage,
                textAlign: TextAlign.center,
                style: AppTextStyles.metaWithColor(context),
              ),
            ),
          )
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: AppSpacing.md,
            children: children,
          ),
      ],
    );
  }
}
