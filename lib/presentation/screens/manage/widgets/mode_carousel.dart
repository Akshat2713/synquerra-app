import 'package:flutter/material.dart';

import '../../../../domain/entities/modes/mode_entity.dart';
import '../../../themes/app_text_styles.dart';
import '../../../themes/app_tokens.dart';
import '../../../themes/colors.dart';
import '../../../utils/app_icons.dart';
import '../../../utils/unit_formatter.dart';
import '../../../widgets/app_motion_widgets.dart';
import '../../../widgets/app_surfaces.dart';

class ModeCarousel extends StatefulWidget {
  final List<ModeEntity> modes;
  final String? selectedId;
  final bool enabled;
  final ValueChanged<ModeEntity> onSelect;
  final ValueChanged<ModeEntity> onDetails;

  const ModeCarousel({
    super.key,
    required this.modes,
    required this.selectedId,
    required this.enabled,
    required this.onSelect,
    required this.onDetails,
  });

  @override
  State<ModeCarousel> createState() => _ModeCarouselState();
}

class _ModeCarouselState extends State<ModeCarousel> {
  final _keys = <String, GlobalKey>{};

  @override
  void initState() {
    super.initState();
    _reveal();
  }

  @override
  void didUpdateWidget(covariant ModeCarousel old) {
    super.didUpdateWidget(old);
    if (old.selectedId != widget.selectedId) _reveal();
  }

  /// Scrolls the selected card to the centre.
  void _reveal() => WidgetsBinding.instance.addPostFrameCallback((_) {
    final ctx = _keys[widget.selectedId]?.currentContext;
    if (ctx == null || !ctx.mounted) return;
    Scrollable.ensureVisible(
      ctx,
      alignment: 0.5,
      duration: AppMotion.slow,
      curve: AppMotion.curve,
    );
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !widget.enabled,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.md,
          AppSpacing.lg,
        ),
        child: Row(
          children: [
            for (final m in widget.modes)
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: _ModeCard(
                  key: _keys.putIfAbsent(m.id, GlobalKey.new),
                  mode: m,
                  isSelected: m.id == widget.selectedId,
                  onTap: () => widget.onSelect(m),
                  onLongPress: () => widget.onDetails(m),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  final ModeEntity mode;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _ModeCard({
    super.key,
    required this.mode,
    required this.isSelected,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primary(context);
    final onPrimary = AppColors.onPrimary(context);

    return Semantics(
      button: true,
      selected: isSelected,
      label: mode.name,
      child: Pressable(
        onTap: onTap,
        onLongPress: onLongPress,
        child: AnimatedContainer(
          duration: AppMotion.base,
          curve: AppMotion.curve,
          width: AppSize.carouselCard,
          padding: AppSpacing.mdAll,
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primaryContainer(context)
                : AppColors.surfaceVariant(context),
            borderRadius: AppRadius.lgAll,
            border: Border.all(
              color: isSelected ? primary : Colors.transparent,
              width: AppSize.stroke,
            ),
            boxShadow: isSelected
                ? AppShadow.glow(primary)
                : AppShadow.soft(AppColors.shadow(context)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconTile(
                    icon: AppIcons.mode(mode),
                    background: isSelected
                        ? primary
                        : AppColors.surface(context),
                    foreground: isSelected
                        ? onPrimary
                        : AppColors.textSecondary(context),
                  ),
                  AnimatedScale(
                    scale: isSelected ? 1 : 0,
                    duration: AppMotion.slow,
                    curve: isSelected ? Curves.elasticOut : Curves.easeIn,
                    child: IconTile(
                      size: AppSize.iconLg,
                      circle: true,
                      icon: Icons.check_rounded,
                      background: primary,
                      foreground: onPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                mode.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodyWithColor(
                  context,
                  color: isSelected
                      ? AppColors.onPrimaryContainer(context)
                      : AppColors.textPrimary(context),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Every ${UnitFormatter.formatDuration(mode.normalSendingInterval)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.metaWithColor(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
