// lib/presentation/widgets/sos_stop_overlay.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/injection_container.dart';
import '../../blocs/sos/sos_bloc.dart';
import '../../themes/app_tokens.dart';
import '../../themes/colors.dart';

class SosStopOverlay extends StatelessWidget {
  final Widget child;
  const SosStopOverlay({super.key, required this.child});

  void _snack(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: AppColors.danger,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bloc = sl<SosBloc>();

    return BlocConsumer<SosBloc, SosState>(
      bloc: bloc,
      listener: (context, state) {
        if (state is SosFailure && state.action == SosAction.stop) {
          _snack(context, state.message);
          bloc.add(const SosReset());
        } else if (state is SosSuccess && state.action == SosAction.stop) {
          _snack(context, 'SOS stopped');
        }
      },
      builder: (context, state) {
        final deviceId = state.activeDeviceId;
        final isStopping =
            state is SosProcessing && state.action == SosAction.stop;

        return Stack(
          children: [
            child,
            if (deviceId != null)
              Positioned(
                left: AppSpacing.md,
                bottom: MediaQuery.of(context).padding.bottom + 96,
                child: ElevatedButton.icon(
                  onPressed: isStopping
                      ? null
                      : () => bloc.add(SosStopSubmit(deviceId: deviceId)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.danger,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.danger.withValues(
                      alpha: 0.6,
                    ),
                    elevation: 6,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    shape: const StadiumBorder(),
                  ),
                  icon: isStopping
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.stop_circle_rounded),
                  label: const Text('STOP SOS'),
                ),
              ),
          ],
        );
      },
    );
  }
}
