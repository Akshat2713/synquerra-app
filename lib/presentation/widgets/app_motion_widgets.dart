import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../themes/app_tokens.dart';

class AnimatedText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final int? maxLines;

  const AnimatedText(
    this.text, {
    super.key,
    required this.style,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) => AnimatedSwitcher(
    duration: AppMotion.base,
    layoutBuilder: (current, previous) => Stack(
      alignment: Alignment.centerLeft,
      children: [...previous, if (current != null) current],
    ),
    child: Text(
      text,
      key: ValueKey(text),
      style: style,
      maxLines: maxLines,
      overflow: maxLines == null ? null : TextOverflow.ellipsis,
    ),
  );
}

class Pressable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const Pressable({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
  });

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _pressed = false;
  void _set(bool v) => setState(() => _pressed = v);

  @override
  Widget build(BuildContext context) => GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTapDown: (_) => _set(true),
    onTapUp: (_) => _set(false),
    onTapCancel: () => _set(false),
    onTap: widget.onTap == null
        ? null
        : () {
            HapticFeedback.selectionClick();
            widget.onTap!();
          },
    onLongPress: widget.onLongPress == null
        ? null
        : () {
            HapticFeedback.mediumImpact();
            widget.onLongPress!();
          },
    child: AnimatedScale(
      scale: _pressed ? AppMotion.pressScale : 1,
      duration: AppMotion.fast,
      curve: AppMotion.curve,
      child: widget.child,
    ),
  );
}

extension AppEntrance on Widget {
  Widget entrance(BuildContext context, {int index = 0}) {
    if (MediaQuery.disableAnimationsOf(context)) return this;
    return animate(delay: AppMotion.stagger * index)
        .fadeIn(duration: AppMotion.slow, curve: AppMotion.curve)
        .slideY(
          begin: AppMotion.slideOffset,
          end: 0,
          duration: AppMotion.slow,
          curve: AppMotion.curve,
        );
  }
}
