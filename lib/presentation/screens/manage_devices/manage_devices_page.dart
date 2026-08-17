import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/device/device_entity.dart';
import '../../../domain/entities/relationship/relationship_entity.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/device_list/device_list_bloc.dart';
import '../../blocs/manage_devices/manage_devices_bloc.dart';
import 'manage_device_screen.dart';

class ManageDevicesPage extends StatefulWidget {
  const ManageDevicesPage({super.key});

  @override
  State<ManageDevicesPage> createState() => _ManageDevicesPageState();
}

class _ManageDevicesPageState extends State<ManageDevicesPage> {
  @override
  void initState() {
    super.initState();
    context.read<ManageDevicesBloc>().add(const ManageDevicesLoadRequested());
  }

  Future<void> _onRefresh() async {
    final deviceListBloc = context.read<DeviceListBloc>();
    final manageBloc = context.read<ManageDevicesBloc>();
    deviceListBloc.add(const DeviceListRefreshRequested());
    manageBloc.add(const ManageDevicesLoadRequested());
    await Future.wait([
      deviceListBloc.stream.firstWhere((s) => s is! DeviceListLoading),
      manageBloc.stream.firstWhere((s) => s is! ManageDevicesLoading),
    ]);
  }

  Future<void> _awaitDone(String deviceId) async {
    final bloc = context.read<ManageDevicesBloc>();
    await bloc.stream.firstWhere(
      (s) => s is ManageDevicesLoaded && s.processingDeviceId != deviceId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final user = authState is AuthAuthenticated ? authState.user : null;

    final deviceListState = context.watch<DeviceListBloc>().state;
    final manageState = context.watch<ManageDevicesBloc>().state;

    final List<DeviceEntity> devices = deviceListState is DeviceListLoaded
        ? deviceListState.devices
        : const [];
    final List<RelationshipEntity> relationships =
        manageState is ManageDevicesLoaded
        ? manageState.relationships
        : const [];

    return ManageDevicesScreen(
      devices: devices,
      relationships: relationships,
      currentUserId: user?.personId ?? '',
      currentUserFullName: user?.fullName ?? '',
      onRefresh: _onRefresh,
      onAssignDevice: (deviceId, personId, associationType) async {
        context.read<ManageDevicesBloc>().add(
          ManageDevicesAssignRequested(
            deviceId: deviceId,
            personId: personId,
            associationType: associationType,
          ),
        );
        await _awaitDone(deviceId);
      },
      onUnassignDevice: (deviceId, personId, associationType) async {
        context.read<ManageDevicesBloc>().add(
          ManageDevicesUnassignRequested(
            deviceId: deviceId,
            personId: personId,
            associationType: associationType,
          ),
        );
        await _awaitDone(deviceId);
      },
    );
  }
}
