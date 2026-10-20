import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/injection_container.dart';
import '../../blocs/sos/sos_bloc.dart';
import '../../themes/app_tokens.dart';
import '../../themes/colors.dart';

class SosStopOverlay extends StatefulWidget {
  final Widget child;
  const SosStopOverlay({super.key, required this.child});

  @override
  State<SosStopOverlay> createState() => _SosStopOverlayState();
}

class _SosStopOverlayState extends State<SosStopOverlay> {
  // Approximate button size, used only for clamping to screen bounds.
  static const _btnW = 160.0;
  static const _btnH = 52.0;

  Offset? _pos; // null until first layout -> initial position applied

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

  Offset _clamp(Offset p, Size size, EdgeInsets safe) {
    final minX = 0.0;
    final maxX = (size.width - _btnW).clamp(0.0, double.infinity);
    final minY = safe.top;
    final maxY = (size.height - safe.bottom - _btnH).clamp(
      minY,
      double.infinity,
    );
    return Offset(p.dx.clamp(minX, maxX), p.dy.clamp(minY, maxY));
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

        final mq = MediaQuery.of(context);
        final size = mq.size;
        final safe = mq.padding;

        // Initial position: bottom-left (same as before).
        final pos = _clamp(
          _pos ?? Offset(AppSpacing.md, size.height - safe.bottom - 96 - _btnH),
          size,
          safe,
        );

        return Stack(
          children: [
            widget.child,
            if (deviceId != null)
              Positioned(
                left: pos.dx,
                top: pos.dy,
                child: GestureDetector(
                  onPanUpdate: (d) =>
                      setState(() => _pos = _clamp(pos + d.delta, size, safe)),
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
              ),
          ],
        );
      },
    );
  }
}
