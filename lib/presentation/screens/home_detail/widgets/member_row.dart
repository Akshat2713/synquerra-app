import 'package:flutter/material.dart';
import '../../../blocs/home_detail/home_detail_bloc.dart';

class MemberRow extends StatelessWidget {
  final List<MemberSummary> members;
  final String selectedId;
  final ValueChanged<String> onSelect;
  final Color highlightColor;

  const MemberRow({
    super.key,
    required this.members,
    required this.selectedId,
    required this.onSelect,
    this.highlightColor = const Color(0xFF3DDC84),
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: members.map((m) {
          final isSelected = m.id == selectedId;
          return GestureDetector(
            onTap: () => onSelect(m.id),
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? highlightColor : Colors.transparent,
                        width: 2.5,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: highlightColor.withOpacity(0.4),
                                blurRadius: 10,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                      color: colors.surfaceContainerHighest,
                    ),
                    alignment: Alignment.center,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Text(
                          m.initials.length >= 2
                              ? m.initials.substring(0, 2)
                              : m.initials,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                        if (m.needsAttention)
                          Positioned(
                            top: -2,
                            right: -14,
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: colors.error,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: colors.surface,
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    m.name,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w400,
                      color: isSelected
                          ? colors.onSurface
                          : colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
