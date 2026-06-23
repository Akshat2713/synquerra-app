import 'package:flutter/material.dart';

class LandingSkeleton extends StatefulWidget {
  const LandingSkeleton({super.key});

  @override
  State<LandingSkeleton> createState() => _LandingSkeletonState();
}

class _LandingSkeletonState extends State<LandingSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) {
        final shimmer = Color.lerp(
          colors.surfaceContainerHighest,
          colors.surfaceContainerHighest.withOpacity(0.3),
          _anim.value,
        )!;

        Widget box(double w, double h, {double r = 10}) => Container(
          width: w,
          height: h,
          decoration: BoxDecoration(
            color: shimmer,
            borderRadius: BorderRadius.circular(r),
          ),
        );

        return SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          child: Column(
            children: [
              // Top banner
              box(double.infinity, 52, r: 16),
              const SizedBox(height: 24),
              // Avatar row (5 circles)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  5,
                  (_) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: shimmer,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Name + status
              Center(child: box(110, 20)),
              const SizedBox(height: 10),
              Center(child: box(160, 14)),
              const SizedBox(height: 10),
              Center(child: box(120, 28, r: 20)),
              const SizedBox(height: 24),
              // Info cards
              for (int i = 0; i < 4; i++) ...[
                box(double.infinity, 68, r: 16),
                const SizedBox(height: 12),
              ],
            ],
          ),
        );
      },
    );
  }
}
