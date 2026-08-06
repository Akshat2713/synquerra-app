import 'package:flutter/material.dart';
import '../../../../domain/entities/modes/mode_entity.dart';
import '../../../utils/mode_icon_resolver.dart';

class TrackingModeCard extends StatefulWidget {
  final List<ModeEntity> modes;
  final String? activeModeId;
  final bool isSwitching;
  final ValueChanged<String> onChanged;

  const TrackingModeCard({
    super.key,
    required this.modes,
    required this.activeModeId,
    required this.isSwitching,
    required this.onChanged,
  });

  @override
  State<TrackingModeCard> createState() => _TrackingModeCardState();
}

class _TrackingModeCardState extends State<TrackingModeCard> {
  // Defaults to Auto mode selected
  bool _isAutoMode = true;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    // Safe lookup: handles empty list during loading/skeleton states without throwing exception
    ModeEntity? activeMode;
    if (widget.modes.isNotEmpty) {
      activeMode = widget.modes.firstWhere(
        (m) => m.id == widget.activeModeId,
        orElse: () => widget.modes.first,
      );
    }

    final modeTitle = activeMode?.name ?? 'Live Tracking';
    final modeDesc = (activeMode != null && activeMode.description.isNotEmpty)
        ? activeMode.description
        : 'Fast updates (~10 sec)';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top Header Row with Auto/Manual on the Right ──────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left column: Section Title & Active Mode Name
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TRACKING MODE:',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: colors.onSurfaceVariant.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      modeTitle,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Right: Compact Auto / Manual Segment Toggle
              SizedBox(
                width: 150,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHighest.withValues(
                      alpha: 0.5,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _SegmentTab(
                          label: 'Auto',
                          isSelected: _isAutoMode,
                          onTap: () => setState(() => _isAutoMode = true),
                        ),
                      ),
                      Expanded(
                        child: _SegmentTab(
                          label: 'Manual',
                          isSelected: !_isAutoMode,
                          onTap: () => setState(() => _isAutoMode = false),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ── Horizontal Scrollable Modes List ──────────────────────
          SizedBox(
            height: 72,
            child: widget.modes.isEmpty
                ? Center(
                    child: Text(
                      'No modes available',
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  )
                : IgnorePointer(
                    ignoring: _isAutoMode || widget.isSwitching,
                    child: Opacity(
                      opacity: _isAutoMode ? 0.4 : 1.0,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: widget.modes.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final mode = widget.modes[index];
                          final isSelected = mode.id == widget.activeModeId;

                          return GestureDetector(
                            onTap: () => widget.onChanged(mode.id),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 72,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? colors.primaryContainer.withValues(
                                        alpha: 0.3,
                                      )
                                    : colors.surfaceContainerHighest.withValues(
                                        alpha: 0.4,
                                      ),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected
                                      ? colors.primary
                                      : Colors.transparent,
                                  width: 1.5,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (widget.isSwitching && isSelected)
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: colors.primary,
                                      ),
                                    )
                                  else
                                    Icon(
                                      ModeIconResolver.resolve(mode),
                                      size: 22,
                                      color: isSelected
                                          ? colors.primary
                                          : colors.onSurfaceVariant,
                                    ),
                                  const SizedBox(height: 4),
                                  Text(
                                    mode.name,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                      color: isSelected
                                          ? colors.primary
                                          : colors.onSurfaceVariant,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 12),
          Text(
            modeDesc,
            style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _SegmentTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SegmentTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? colors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? colors.onSurface : colors.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
