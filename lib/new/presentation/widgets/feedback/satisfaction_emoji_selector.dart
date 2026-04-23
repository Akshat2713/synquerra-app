// lib/presentation/widgets/feedback/satisfaction_emoji_selector.dart
import 'package:flutter/material.dart';
import '../../themes/colors.dart';

class SatisfactionEmojiSelector extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onSelected;

  SatisfactionEmojiSelector({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<String> _emojis = ['😞', '😟', '😐', '😊', '😄'];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(_emojis.length, (index) {
        final isSelected = selectedIndex == index;
        return GestureDetector(
          onTap: () => onSelected(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.safeGreen.withOpacity(0.2)
                  : Colors.transparent,
              border: Border.all(
                color: isSelected ? colorScheme.primary : Colors.grey,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(_emojis[index], style: const TextStyle(fontSize: 32)),
          ),
        );
      }),
    );
  }
}
