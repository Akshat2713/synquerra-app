// lib/presentation/screens/manage/manage_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../domain/entities/device/device_entity.dart';
import '../../blocs/manage/manage_bloc.dart';
import '../../themes/colors.dart';
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
        body: BlocConsumer<ManageBloc, ManageState>(
          listener: (context, state) {
            if (state is! ManageLoaded) return;

            if (state.modeSwitchError != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.modeSwitchError!),
                  backgroundColor: AppColors.danger,
                ),
              );
            }

            if (state.settingsUpdateError != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.settingsUpdateError!),
                  backgroundColor: AppColors.danger,
                ),
              );
            }
          },
          builder: (context, state) {
            final isLoading = state is ManageLoading || state is ManageInitial;
            final errorMessage = state is ManageError ? state.message : null;

            if (isLoading) {
              return ManageSkeleton(device: widget.device);
            }

            return AsyncStateView(
              isLoading: false,
              errorMessage: errorMessage,
              onRetry: () {
                _manageBloc.add(ManageLoadRequested(widget.device));
              },
              builder: () {
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
            );
          },
        ),
      ),
    );
  }
}
