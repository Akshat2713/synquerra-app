// lib/presentation/screens/main_shell/modern_bottom_bar.dart
import 'package:flutter/material.dart';
import '../../themes/colors.dart';
import '../../themes/app_tokens.dart';

class BarItem {
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  const BarItem(this.label, this.icon, this.selectedIcon);
}

class BottomBar extends StatelessWidget {
  static const double barHeight = 64; // visible bar, excluding safe-area inset
  static const double bump = 24; // how far the button rises above the bar
  static const double _fabSize = 58;

  final List<BarItem> items; // even count: split around the center button
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final VoidCallback onCenterTap;
  final String centerTooltip;

  const BottomBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
    required this.onCenterTap,
    this.centerTooltip = 'Add New Device',
  });

  @override
  Widget build(BuildContext context) {
    final inset = MediaQuery.paddingOf(context).bottom;
    final half = items.length ~/ 2;

    Widget slot(int i) => Expanded(
      child: _NavItem(
        item: items[i],
        selected: i == selectedIndex,
        onTap: () => onSelected(i),
      ),
    );

    return SizedBox(
      height: bump + barHeight + inset,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            top: bump,
            child: CustomPaint(
              painter: _BumpBarPainter(
                color: AppColors.surface(context),
                borderColor: AppColors.outlineVariant(context),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: bump,
            height: barHeight,
            child: Row(
              children: [
                for (var i = 0; i < half; i++) slot(i),
                const SizedBox(width: 92), // room for the button
                for (var i = half; i < items.length; i++) slot(i),
              ],
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Center(
              child: Tooltip(
                message: centerTooltip,
                child: Container(
                  width: _fabSize,
                  height: _fabSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.primaryGradient(context),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary(
                          context,
                        ).withValues(alpha: 0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    shape: const CircleBorder(),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: onCenterTap,
                      child: Icon(
                        Icons.add_rounded,
                        color: AppColors.onPrimary(context),
                        size: 30,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final BarItem item;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primary(context);
    final inactive = AppColors.iconSecondary(context);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            width: selected ? 52 : 40,
            height: 32,
            decoration: BoxDecoration(
              color: selected
                  ? primary.withValues(alpha: 0.12)
                  : Colors.transparent,
              borderRadius: AppRadius.pillAll,
            ),
            child: Icon(
              selected ? item.selectedIcon : item.icon,
              size: 24,
              color: selected ? primary : inactive,
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            child: selected
                ? Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      item.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _BumpBarPainter extends CustomPainter {
  final Color color;
  final Color borderColor;
  _BumpBarPainter({required this.color, required this.borderColor});

  @override
  void paint(Canvas canvas, Size size) {
    const r = 26.0; // top corner radius
    const depth = 40.0; // bump depth
    const half = 62.0; // half width of the bump
    final w = size.width, h = size.height, cx = w / 2;

    final path = Path()
      ..moveTo(0, r)
      ..quadraticBezierTo(0, 0, r, 0)
      ..lineTo(cx - half - 14, 0)
      ..cubicTo(cx - half + 26, 0, cx - 34, depth, cx, depth)
      ..cubicTo(cx + 34, depth, cx + half - 26, 0, cx + half + 14, 0)
      ..lineTo(w - r, 0)
      ..quadraticBezierTo(w, 0, w, r)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();

    canvas.drawShadow(path, Colors.black.withValues(alpha: 0.45), 10, false);
    canvas.drawPath(path, Paint()..color = color);
    // hairline on top edge keeps the bar defined in dark mode
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8
        ..color = borderColor.withValues(alpha: 0.6),
    );
  }

  @override
  bool shouldRepaint(_BumpBarPainter old) =>
      old.color != color || old.borderColor != borderColor;
}
