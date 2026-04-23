// lib/presentation/widgets/indicators/pulse_indicator.dart
import 'package:flutter/material.dart';

class PulseIndicator extends StatefulWidget {
  final bool isActive;
  final double size;

  const PulseIndicator({super.key, required this.isActive, this.size = 12});

  @override
  State<PulseIndicator> createState() => _PulseIndicatorState();
}

class _PulseIndicatorState extends State<PulseIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    if (widget.isActive) {
      _animationController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(PulseIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !_animationController.isAnimating) {
      _animationController.repeat(reverse: true);
    } else if (!widget.isActive && _animationController.isAnimating) {
      _animationController.stop();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isActive ? Colors.green : Colors.red;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final value = _animationController.value;
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.4),
                blurRadius: 8 * (1 + value * 0.5),
                spreadRadius: 2 * (1 + value * 0.5),
              ),
            ],
          ),
        );
      },
    );
  }
}
