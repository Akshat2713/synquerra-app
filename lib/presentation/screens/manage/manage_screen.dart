import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../domain/entities/device/device_entity.dart';
import '../../blocs/manage/manage_bloc.dart';
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
        body: BlocConsumer<ManageBloc, ManageState>(
          listener: (context, state) {
            if (state is! ManageLoaded) return;
            final colors = Theme.of(context).colorScheme;

            // Handle Mode Switch Failures
            if (state.modeSwitchError != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.modeSwitchError!),
                  backgroundColor: colors.error,
                ),
              );
            }

            // Handle Phone Number Update Failures
            if (state.settingsUpdateError != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.settingsUpdateError!),
                  backgroundColor: colors.error,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is ManageLoading || state is ManageInitial) {
              return ManageSkeleton(device: widget.device);
            }

            if (state is ManageError) {
              return _ErrorView(
                message: state.message,
                onRetry: () {
                  context.read<ManageBloc>().add(
                    ManageLoadRequested(widget.device),
                  );
                },
              );
            }

            if (state is ManageLoaded) {
              return ManageBody(
                device: widget.device,
                settings: state.settings,
                modes: state.modes,
                activeModeId: state.activeModeId,
                isSwitchingMode: state.isSwitchingMode,
                isUpdatingSettings: state.isUpdatingSettings,
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline_rounded, size: 48, color: colors.error),
          const SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(color: colors.error),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
