// lib/presentation/screens/manage/widgets/mode_picker_row.dart

import 'package:flutter/material.dart';
import '../../../../domain/entities/modes/mode_entity.dart';
import '../../../themes/colors.dart';
import '../../../utils/mode_icon_resolver.dart';
import 'mode_details_sheet.dart';

class ModePickerRow extends StatelessWidget {
  final List<ModeEntity> modes;
  final String? activeModeId;
  final bool isSwitching;
  final bool autoModeSwitch;
  final VoidCallback onAutoModeToggle;
  final ValueChanged<String> onChanged;

  const ModePickerRow({
    super.key,
    required this.modes,
    required this.activeModeId,
    required this.isSwitching,
    required this.autoModeSwitch,
    required this.onAutoModeToggle,
    required this.onChanged,
  });

  void _setAuto(bool value) {
    if (value == autoModeSwitch || isSwitching) return;
    onAutoModeToggle();
  }

  @override
  Widget build(BuildContext context) {
    ModeEntity? activeMode;
    if (modes.isNotEmpty) {
      activeMode = modes.firstWhere(
        (m) => m.id == activeModeId,
        orElse: () => modes.first,
      );
    }

    final modeDesc = (activeMode != null && activeMode.description.isNotEmpty)
        ? activeMode.description
        : 'Fast updates (~10 sec)';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.outline(context).withValues(alpha: 0.8),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  'TRACKING MODE',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: AppColors.textPrimary(
                      context,
                    ).withValues(alpha: 0.8),
                  ),
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
                          isSelected: autoModeSwitch,
                          onTap: () => _setAuto(true),
                        ),
                      ),
                      Expanded(
                        child: _SegmentTab(
                          label: 'Manual',
                          isSelected: !autoModeSwitch,
                          onTap: () => _setAuto(false),
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
            height: 90,
            child: modes.isEmpty
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
                    ignoring: autoModeSwitch || isSwitching,
                    child: Opacity(
                      opacity: autoModeSwitch ? 0.4 : 1.0,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: modes.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final mode = modes[index];
                          final isSelected = mode.id == activeModeId;

                          return GestureDetector(
                            onTap: () => onChanged(mode.id),
                            onLongPress: () =>
                                showModeDetailsSheet(context, mode),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 72,
                              padding: const EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primaryContainer(
                                        context,
                                      ).withValues(alpha: 0.3)
                                    : AppColors.surfaceVariant(context),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary(context)
                                      : Colors.transparent,
                                  width: 1.5,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (isSwitching && isSelected)
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
                                          ? AppColors.primary(context)
                                          : AppColors.textSecondary(context),
                                    ),
                                  const SizedBox(height: 4),
                                  Text(
                                    mode.name,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                      color: isSelected
                                          ? AppColors.primary(context)
                                          : AppColors.textSecondary(context),
                                    ),
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
