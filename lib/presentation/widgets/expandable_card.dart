import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:synquerra/presentation/themes/app_text_styles.dart';
import 'package:synquerra/presentation/themes/app_tokens.dart';
import 'package:synquerra/presentation/themes/colors.dart';
import 'package:synquerra/presentation/widgets/app_surfaces.dart';

/// Collapsible card: leading tile + title + right chevron.
class ExpandableCard extends StatefulWidget {
  const ExpandableCard({
    super.key,
    required this.title,
    required this.child,
    this.leading,
    this.initiallyExpanded = false,
  });

  final String title;
  final Widget child;
  final Widget? leading;
  final bool initiallyExpanded;

  @override
  State<ExpandableCard> createState() => _ExpandableCardState();
}

class _ExpandableCardState extends State<ExpandableCard> {
  late bool _expanded = widget.initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : AppMotion.base;

    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Material(
            type: MaterialType.transparency,
            borderRadius: AppRadius.lgAll,
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _expanded = !_expanded);
              },
              child: Padding(
                padding: AppSpacing.mdAll,
                child: Row(
                  children: [
                    if (widget.leading != null) ...[
                      widget.leading!,
                      const SizedBox(width: AppSpacing.smd),
                    ],
                    Expanded(
                      child: Text(
                        widget.title,
                        style: AppTextStyles.sectionWithColor(context),
                      ),
                    ),
                    AnimatedRotation(
                      turns: _expanded ? 0.5 : 0,
                      duration: duration,
                      curve: AppMotion.curve,
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: AppColors.primary(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          AnimatedSize(
            duration: duration,
            curve: AppMotion.curve,
            alignment: Alignment.topCenter,
            child: _expanded
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      0,
                      AppSpacing.md,
                      AppSpacing.md,
                    ),
                    child: widget.child,
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}

/// Empty-state line used inside an [ExpandableCard].
class ExpandableCardEmpty extends StatelessWidget {
  const ExpandableCardEmpty(this.message, {super.key});
  final String message;

  @override
  Widget build(BuildContext context) => Padding(
    padding: AppSpacing.smAll,
    child: Text(message, style: AppTextStyles.metaWithColor(context)),
  );
}
