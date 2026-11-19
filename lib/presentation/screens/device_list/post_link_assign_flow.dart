// lib/presentation/screens/device_list/post_link_assign_flow.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/injection_container.dart';
import '../../../domain/entities/device/device_entity.dart';
import '../../../domain/entities/relationship/relationship_entity.dart';
import '../../app/app_router.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/device_list/device_list_bloc.dart';
import '../../blocs/manage_devices/manage_devices_bloc.dart';
import '../../blocs/manage_users/manage_users_bloc.dart';
import '../../widgets/app_overlays.dart';
import '../manage_devices/widgets/assign_member_sheet.dart';

class PostLinkAssignFlow {
  PostLinkAssignFlow._();

  static int _active = 0;

  /// True while any assign sheet flow is running (prevents stacked sheets).
  static bool get isRunning => _active > 0;

  /// After linking: refresh, find the new device by serial, offer assignment.
  static Future<void> start(BuildContext context, String serialNo) async {
    _active++;
    try {
      final deviceListBloc = context.read<DeviceListBloc>();

      final loaded = deviceListBloc.stream
          .firstWhere(
            (s) =>
                s is DeviceListLoaded &&
                s.devices.any((d) => d.serialNo == serialNo),
          )
          .timeout(const Duration(seconds: 10));
      deviceListBloc.add(const DeviceListRefreshRequested());

      DeviceEntity device;
      try {
        final state = await loaded as DeviceListLoaded;
        device = state.devices.firstWhere((d) => d.serialNo == serialNo);
      } catch (_) {
        return;
      }
      if (!context.mounted) return;
      await assignCarrier(context, device);
    } finally {
      _active--;
    }
  }

  /// Opens the assign sheet for each device, one after another.
  static Future<void> promptForUnassigned(
    BuildContext context,
    List<DeviceEntity> devices,
  ) async {
    if (isRunning) return;
    _active++;
    try {
      for (final d in devices) {
        if (!context.mounted) return;
        await assignCarrier(context, d);
      }
    } finally {
      _active--;
    }
  }

  /// Mandatory first-carrier flow: carrier role only, cannot be skipped.
  static Future<void> assignCarrier(
    BuildContext context,
    DeviceEntity device,
  ) async {
    final deviceListBloc = context.read<DeviceListBloc>();
    final auth = context.read<AuthBloc>().state;
    if (auth is! AuthAuthenticated) return;
    final user = auth.user;

    _active++;
    final manageBloc = sl<ManageDevicesBloc>(param1: deviceListBloc);
    final usersBloc = sl<ManageUsersBloc>();

    try {
      Future<List<RelationshipEntity>> loadRelationships() async {
        final next = manageBloc.stream.firstWhere(
          (s) => s is ManageDevicesLoaded || s is ManageDevicesError,
        );
        manageBloc.add(const ManageDevicesLoadRequested());
        final s = await next;
        return s is ManageDevicesLoaded ? s.relationships : const [];
      }

      Future<void> openSheet() async {
        final relationships = await loadRelationships();
        if (!context.mounted) return;

        Future<ManageDevicesState>? assignDone;
        var addingMember = false;

        await AssignMemberSheet.show(
          context,
          device: device,
          currentUserId: user.personId,
          currentUserFullName: user.fullName,
          relationships: relationships,
          carrierOnly: true, // only the carrier role
          dismissible: false, // cannot be skipped
          onAssign: (personId, type) {
            // Subscribe BEFORE dispatching: wait for "processing" to start,
            // then for it to clear (success or failure).
            assignDone = manageBloc.stream
                .skipWhile(
                  (s) =>
                      !(s is ManageDevicesLoaded &&
                          s.processingDeviceId == device.id),
                )
                .firstWhere(
                  (s) =>
                      s is ManageDevicesLoaded && s.processingDeviceId == null,
                )
                .timeout(const Duration(seconds: 20));
            manageBloc.add(
              ManageDevicesAssignRequested(
                deviceId: device.id,
                personId: personId,
                associationType: type,
              ),
            );
          },
          onAddMember: () => addingMember = true,
        );

        if (!context.mounted) return;

        // Went to "Add member": come back and ask again.
        if (addingMember) {
          await AppRouter.pushAddMember<bool>(context, bloc: usersBloc);
          if (context.mounted) await openSheet(); // reopen with fresh list
          return;
        }

        // Picked someone: success ends the flow, failure asks again.
        if (assignDone != null) {
          try {
            final s = await assignDone!;
            if (!context.mounted) return;
            if (s is ManageDevicesLoaded && s.errorMessage != null) {
              AppSnackBar.error(context, s.errorMessage!);
              await openSheet(); // carrier is mandatory: retry
            } else {
              AppSnackBar.success(context, 'Carrier assigned');
            }
          } catch (_) {
            // timeout: the list refresh will still reflect the real state
          }
          return;
        }

        // Sheet closed without a choice (shouldn't happen): ask again.
        await openSheet();
      }

      await openSheet();
    } finally {
      _active--;
      await manageBloc.close();
      await usersBloc.close();
    }
  }
}
