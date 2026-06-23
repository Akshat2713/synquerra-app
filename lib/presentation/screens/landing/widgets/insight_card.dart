import 'package:flutter/material.dart';
import '../../../blocs/landing/landing_bloc.dart';

class InsightCard extends StatelessWidget {
  final String insightText;
  final RiskLevel riskLevel;

  const InsightCard({
    super.key,
    required this.insightText,
    required this.riskLevel,
  });

  Color _riskColor(ColorScheme c) => switch (riskLevel) {
    RiskLevel.low => const Color(0xFF3DDC84),
    RiskLevel.medium => const Color(0xFFFFB300),
    RiskLevel.high => c.error,
  };

  String _actionLabel() => switch (riskLevel) {
    RiskLevel.low => 'No action required',
    RiskLevel.medium => 'Monitor closely',
    RiskLevel.high => 'Action recommended',
  };

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final rc = _riskColor(colors);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outlineVariant, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'INSIGHT',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
              Text(
                'RISK LEVEL',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Text(
                  insightText,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: rc,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: rc.withOpacity(0.5),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.check_circle_outline_rounded, color: rc, size: 16),
              const SizedBox(width: 6),
              Text(
                _actionLabel(),
                style: TextStyle(
                  fontSize: 13,
                  color: rc,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
