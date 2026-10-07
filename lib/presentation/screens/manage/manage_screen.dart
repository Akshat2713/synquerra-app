// lib/presentation/screens/manage/manage_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../domain/entities/device/device_entity.dart';
import '../../blocs/manage/manage_bloc.dart';
import '../../themes/colors.dart';
import '../../widgets/async_state_view.dart';
import 'manage_skeleton.dart';
import 'widgets/emergency_contacts_section.dart';
import 'widgets/mode_picker_row.dart';

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

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.danger),
    );
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
              _showError(context, state.modeSwitchError!);
            }
            if (state.settingsUpdateError != null) {
              _showError(context, state.settingsUpdateError!);
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
                  return ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      ModePickerRow(
                        modes: state.modes,
                        activeModeId: state.activeModeId,
                        isSwitching: state.isSwitchingMode,
                        autoModeSwitch: state.settings.autoModeSwitch,
                        onAutoModeToggle: () => _manageBloc.add(
                          ManageAutoModeToggleRequested(widget.device.id),
                        ),
                        onChanged: (modeId) => _manageBloc.add(
                          ManageModeSwitchRequested(
                            deviceId: widget.device.id,
                            modeId: modeId,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      EmergencyContactsSection(
                        deviceId: widget.device.id,
                        settings: state.settings,
                        isUpdating: state.isUpdatingSettings,
                        onSaveContacts: (phoneNum1, phoneNum2) =>
                            _manageBloc.add(
                              ManagePhoneNumbersUpdateRequested(
                                deviceId: widget.device.id,
                                phoneNum1: phoneNum1,
                                phoneNum2: phoneNum2,
                              ),
                            ),
                      ),
                    ],
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
