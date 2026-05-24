import 'package:flutter/material.dart';

class NetworkCard extends StatelessWidget {
  final String sim1Label;
  final String sim1Carrier;
  final String sim1DataLeft;
  final int sim1SignalBars;

  final String sim2Label;
  final String sim2Carrier;
  final String sim2DataLeft;
  final int sim2SignalBars;

  final VoidCallback onSwitchSim;

  const NetworkCard({
    super.key,
    required this.sim1Label,
    required this.sim1Carrier,
    required this.sim1DataLeft,
    required this.sim1SignalBars,
    required this.sim2Label,
    required this.sim2Carrier,
    required this.sim2DataLeft,
    required this.sim2SignalBars,
    required this.onSwitchSim,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      children: [
        // SIM 1 – active
        Expanded(
          child: _SimTile(
            label: sim1Label,
            carrier: sim1Carrier,
            dataLeft: sim1DataLeft,
            signalBars: sim1SignalBars,
            isActive: true,
            onTap: null,
            colors: colors,
          ),
        ),
        const SizedBox(width: 8),
        // SIM 2 – switch
        Expanded(
          child: _SimTile(
            label: sim2Label,
            carrier: sim2Carrier,
            dataLeft: sim2DataLeft,
            signalBars: sim2SignalBars,
            isActive: false,
            onTap: onSwitchSim,
            colors: colors,
          ),
        ),
      ],
    );
  }
}

class _SimTile extends StatelessWidget {
  final String label;
  final String carrier;
  final String dataLeft;
  final int signalBars;
  final bool isActive;
  final VoidCallback? onTap;
  final ColorScheme colors;

  const _SimTile({
    required this.label,
    required this.carrier,
    required this.dataLeft,
    required this.signalBars,
    required this.isActive,
    required this.onTap,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isActive
              ? colors.primaryContainer.withOpacity(0.4)
              : colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: isActive
              ? Border.all(color: colors.primary.withOpacity(0.6), width: 1.5)
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isActive ? colors.primary : colors.onSurfaceVariant,
                  ),
                ),
                _SignalBarsIcon(
                  bars: signalBars,
                  isActive: isActive,
                  colors: colors,
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              carrier,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 2),
            Text(
              dataLeft,
              style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _SignalBarsIcon extends StatelessWidget {
  final int bars; // 0-4
  final bool isActive;
  final ColorScheme colors;

  const _SignalBarsIcon({
    required this.bars,
    required this.isActive,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = isActive ? colors.primary : colors.onSurface;
    final inactiveColor = colors.outlineVariant;
    final heights = [6.0, 9.0, 12.0, 15.0];

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(4, (i) {
        final filled = i < bars;
        return Container(
          width: 4,
          height: heights[i],
          margin: const EdgeInsets.only(left: 2),
          decoration: BoxDecoration(
            color: filled ? activeColor : inactiveColor,
            borderRadius: BorderRadius.circular(1),
          ),
        );
      }),
    );
  }
}
