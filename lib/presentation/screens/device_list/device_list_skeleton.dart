import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:synquerra/presentation/themes/app_tokens.dart';

class DeviceListSkeleton extends StatelessWidget {
  const DeviceListSkeleton({super.key});

  Widget _shimmerBox({
    required double width,
    required double height,
    double radius = 8,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  Widget _cardSkeleton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.lgAll,
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _shimmerBox(width: 44, height: 44, radius: 12),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _shimmerBox(width: 140, height: 14),
                  const SizedBox(height: AppSpacing.xs),
                  _shimmerBox(width: 100, height: 11),
                ],
              ),
              const Spacer(),
              _shimmerBox(width: 24, height: 24, radius: 12),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              _shimmerBox(width: 60, height: 12),
              const SizedBox(width: 16),
              _shimmerBox(width: 60, height: 12),
              const SizedBox(width: 16),
              _shimmerBox(width: 60, height: 12),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              _shimmerBox(width: 80, height: 12),
              const Spacer(),
              _shimmerBox(width: 70, height: 26, radius: 20),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade50,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          children: [
            // Banner skeleton
            Container(
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              height: 64,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: AppRadius.mdAll,
              ),
            ),
            const SizedBox(height: 8),
            // Card skeletons
            _cardSkeleton(),
            _cardSkeleton(),
            _cardSkeleton(),
          ],
        ),
      ),
    );
  }
}
