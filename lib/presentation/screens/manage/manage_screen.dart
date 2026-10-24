import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../domain/entities/device/device_entity.dart';
import '../../blocs/manage/manage_bloc.dart';
import '../../widgets/app_overlays.dart';
import '../../widgets/async_state_view.dart';
import 'manage_skeleton.dart';
import 'widgets/manage_body.dart';

class ManageScreen extends StatefulWidget {
  final DeviceEntity device;
  const ManageScreen({super.key, required this.device});

  @override
  State<ManageScreen> createState() => _ManageScreenState();
}

class _ManageScreenState extends State<ManageScreen> {
  late final ManageBloc _manageBloc;

  @override
  void initState() {
    super.initState();
    _manageBloc = sl<ManageBloc>()..add(ManageLoadRequested(widget.device));
  }

  @override
  void dispose() {
    _manageBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _manageBloc,
      child: Scaffold(
        appBar: AppBar(title: const Text('Manage'), centerTitle: false),
        body: _ManageFeedbackListener(
          child: BlocBuilder<ManageBloc, ManageState>(
            builder: (context, state) {
              if (state is ManageLoading || state is ManageInitial) {
                return ManageSkeleton(device: widget.device);
              }
              return AsyncStateView(
                isLoading: false,
                errorMessage: state is ManageError ? state.message : null,
                onRetry: () =>
                    _manageBloc.add(ManageLoadRequested(widget.device)),
                builder: () => state is ManageLoaded
                    ? ManageBody(device: widget.device, state: state)
                    : const SizedBox.shrink(),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Shows one snackbar when an action finishes. Wraps the screen body.
class _ManageFeedbackListener extends StatefulWidget {
  final Widget child;
  const _ManageFeedbackListener({required this.child});

  @override
  State<_ManageFeedbackListener> createState() =>
      _ManageFeedbackListenerState();
}

class _ManageFeedbackListenerState extends State<_ManageFeedbackListener> {
  ManageLoaded? _prev;

  ({String text, bool isError})? _messageFor(ManageLoaded p, ManageLoaded s) {
    if (s.modeSwitchError != null && s.modeSwitchError != p.modeSwitchError) {
      return (text: s.modeSwitchError!, isError: true);
    }
    if (s.settingsUpdateError != null &&
        s.settingsUpdateError != p.settingsUpdateError) {
      return (text: s.settingsUpdateError!, isError: true);
    }
    if (p.settings.autoModeSwitch != s.settings.autoModeSwitch) {
      return (
        text: s.settings.autoModeSwitch
            ? 'Auto Mode turned on'
            : 'Auto Mode turned off',
        isError: false,
      );
    }
    if (p.isSwitchingMode && !s.isSwitchingMode) {
      final name = s.modes
          .where((m) => m.id == s.activeModeId)
          .map((m) => m.name)
          .firstOrNull;
      return (
        text: name == null ? 'Mode switched' : 'Switched to $name',
        isError: false,
      );
    }
    if (p.isUpdatingSettings && !s.isUpdatingSettings) {
      return (text: 'Emergency contacts updated', isError: false);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ManageBloc, ManageState>(
      listener: (context, state) {
        if (state is! ManageLoaded) {
          _prev = null;
          return;
        }
        final prev = _prev;
        _prev = state;
        if (prev == null) return;

        final m = _messageFor(prev, state);
        if (m == null) return;
        m.isError
            ? AppSnackBar.error(context, m.text)
            : AppSnackBar.success(context, m.text);
      },
      child: widget.child,
    );
  }
}
