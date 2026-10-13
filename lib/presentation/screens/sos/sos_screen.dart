// presentation/screens/alerts/sos_alert_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/app_logger.dart';
import '../../../domain/entities/realtime/device_alert.dart';
import '../../blocs/sos/sos_bloc.dart';
import '../../themes/app_text_styles.dart';
import '../../themes/app_tokens.dart';
import '../../themes/colors.dart';

class SosScreen extends StatefulWidget {
  final DeviceAlert alert;
  final String deviceName;

  const SosScreen({super.key, required this.alert, required this.deviceName});

  @override
  State<SosScreen> createState() => _SosAlertScreenState();
}

class _SosAlertScreenState extends State<SosScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _acknowledge(BuildContext context) {
    context.read<SosBloc>().add(
      SosAcknowledgeSubmit(
        alertId: widget.alert.id,
        deviceId: widget.alert.deviceId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String ownerName = widget.deviceName;
    AppLogger.d('SOS Screen', 'The owner name received is $ownerName');

    // Using LayoutBuilder to calculate full-width pulse sizes dynamically
    return PopScope(
      canPop: false,
      child: BlocConsumer<SosBloc, SosState>(
        listener: (context, state) {
          if (state is SosSuccess && state.action == SosAction.acknowledge) {
            Navigator.of(context).pop();
          } else if (state is SosFailure &&
              state.action == SosAction.acknowledge) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.danger,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
              ),
            );
            context.read<SosBloc>().add(const SosReset());
          }
        },
        builder: (context, state) {
          final isLoading =
              state is SosProcessing && state.action == SosAction.acknowledge;

          return Scaffold(
            backgroundColor: AppColors.dangerContainer.withValues(alpha: 0.15),
            body: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Calculate size to span near full screen width (minus padding)
                  final double maxPulseSize = constraints.maxWidth - 40;
                  const double buttonSize = 180;

                  return Padding(
                    padding: AppSpacing.mdAll,
                    child: Column(
                      children: [
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          widget.deviceName,
                          style: AppTextStyles.display.copyWith(
                            color: AppColors.danger,
                            fontSize: 26,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          widget.alert.description,
                          style: AppTextStyles.meta.copyWith(
                            color: AppColors.textSecondary(context),
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        // Increased top spacer so the button sits in the upper portion of the down half
                        const Spacer(flex: 2),
                        Center(
                          child: SizedBox(
                            width: maxPulseSize,
                            height: maxPulseSize,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Outer Pulse Animation (reaches almost full width)
                                AnimatedBuilder(
                                  animation: _pulseController,
                                  builder: (context, child) {
                                    final value = _pulseController.value;
                                    return Container(
                                      width:
                                          buttonSize +
                                          (value * (maxPulseSize - buttonSize)),
                                      height:
                                          buttonSize +
                                          (value * (maxPulseSize - buttonSize)),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppColors.danger.withValues(
                                          alpha: (1 - value) * 0.3,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                // Inner Pulse Animation (delayed ripple)
                                AnimatedBuilder(
                                  animation: _pulseController,
                                  builder: (context, child) {
                                    final delayValue =
                                        (_pulseController.value + 0.5) % 1.0;
                                    return Container(
                                      width:
                                          buttonSize +
                                          (delayValue *
                                              ((maxPulseSize - buttonSize) *
                                                  0.7)),
                                      height:
                                          buttonSize +
                                          (delayValue *
                                              ((maxPulseSize - buttonSize) *
                                                  0.7)),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppColors.danger.withValues(
                                          alpha: (1 - delayValue) * 0.35,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                // Main Interactive SOS Button (~180x180)
                                GestureDetector(
                                  onTap: isLoading
                                      ? null
                                      : () => _acknowledge(context),
                                  child: Container(
                                    width: buttonSize,
                                    height: buttonSize,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors: [
                                          AppColors.danger,
                                          AppColors.danger.withValues(
                                            alpha: 0.8,
                                          ),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.danger.withValues(
                                            alpha: 0.5,
                                          ),
                                          blurRadius: 25,
                                          spreadRadius: 8,
                                        ),
                                      ],
                                    ),
                                    child: isLoading
                                        ? const Center(
                                            child: SizedBox(
                                              width: 48,
                                              height: 48,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 4,
                                                color: Colors.white,
                                              ),
                                            ),
                                          )
                                        : Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const Icon(
                                                Icons.sos_rounded,
                                                color: Colors.white,
                                                size: 64,
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                'ACKNOWLEDGE',
                                                style: AppTextStyles.micro
                                                    .copyWith(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      letterSpacing: 1.5,
                                                      fontSize: 12,
                                                    ),
                                              ),
                                            ],
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Spacer(flex: 1),
                        Text(
                          'TAP TO ACKNOWLEDGE',
                          style: AppTextStyles.section.copyWith(
                            color: AppColors.textPrimary(context),
                            letterSpacing: 1.2,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                      ],
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
