// lib/presentation/screens/manage/widgets/mode_picker_row.dart

import 'package:flutter/material.dart';
import '../../../../domain/entities/modes/mode_entity.dart';
import '../../../themes/colors.dart';
import '../../../utils/mode_icon_resolver.dart';

class TrackingModeCard extends StatefulWidget {
  final List<ModeEntity> modes;
  final String? activeModeId;
  final bool isSwitching;
  final bool autoModeSwitch;
  final ValueChanged<String> onChanged;

  const TrackingModeCard({
    super.key,
    required this.modes,
    required this.activeModeId,
    required this.isSwitching,
    required this.autoModeSwitch,
    required this.onChanged,
  });

  @override
  State<TrackingModeCard> createState() => _TrackingModeCardState();
}

class _TrackingModeCardState extends State<TrackingModeCard> {
  late bool _isAutoMode;

  @override
  void initState() {
    super.initState();
    _isAutoMode = widget.autoModeSwitch;
  }

  @override
  void didUpdateWidget(covariant TrackingModeCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.autoModeSwitch != widget.autoModeSwitch) {
      setState(() {
        _isAutoMode = widget.autoModeSwitch;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.outlineVariant(context).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                        color: AppColors.textSecondary(
                          context,
                        ).withValues(alpha: 0.6),
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
              SizedBox(
                width: 150,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant(
                      context,
                    ).withValues(alpha: 0.5),
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
          SizedBox(
            height: 72,
            child: widget.modes.isEmpty
                ? Center(
                    child: Text(
                      'No modes available',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary(context),
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
                                    ? AppColors.primaryContainer.withValues(
                                        alpha: 0.3,
                                      )
                                    : AppColors.surfaceVariant(
                                        context,
                                      ).withValues(alpha: 0.4),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : Colors.transparent,
                                  width: 1.5,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (widget.isSwitching && isSelected)
                                    const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator.adaptive(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  else
                                    Icon(
                                      ModeIconResolver.resolve(mode),
                                      size: 22,
                                      color: isSelected
                                          ? AppColors.primary
                                          : AppColors.textSecondary(context),
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
                                          ? AppColors.primary
                                          : AppColors.textSecondary(context),
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
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary(context),
            ),
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
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surface(context) : Colors.transparent,
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
              color: isSelected
                  ? AppColors.textPrimary(context)
                  : AppColors.textSecondary(context),
            ),
          ),
        ),
      ),
    );
  }
}
