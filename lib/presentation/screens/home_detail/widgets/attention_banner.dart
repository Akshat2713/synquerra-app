import 'package:flutter/material.dart';
import '../../../blocs/home_detail/home_detail_bloc.dart'; // Adjust path based on your exact domain structure

class AttentionBanner extends StatelessWidget {
  final int attentionCount;
  final int totalMembers;
  final List<MemberSummary> members;
  final VoidCallback onTap;

  const AttentionBanner({
    super.key,
    required this.attentionCount,
    required this.totalMembers,
    required this.members,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    const dotColors = [
      Color(0xFFFF5252),
      Color(0xFFFFB300),
      Color(0xFF3DDC84),
      Color(0xFF5B8DEF),
      Color(0xFFAB47BC),
    ];

    return Material(
      color: colors.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: colors.outline, width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Row(
                children: List.generate(
                  members.length.clamp(0, 5),
                  (i) => Container(
                    width: 10,
                    height: 10,
                    margin: const EdgeInsets.only(right: 4),
                    decoration: BoxDecoration(
                      color: members[i].needsAttention
                          ? colors.error
                          : dotColors[i % dotColors.length],
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$attentionCount needs attention',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      '$totalMembers members',
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              _AvatarStack(members: members),
              const SizedBox(width: 6),
              Icon(
                Icons.chevron_right_rounded,
                color: colors.onSurfaceVariant,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AvatarStack extends StatelessWidget {
  final List<MemberSummary> members;
  const _AvatarStack({required this.members});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    const size = 28.0;
    const overlap = 10.0;
    final shown = members.take(3).toList();
    final extra = members.length - shown.length;

    return SizedBox(
      width:
          size + (shown.length - 1) * (size - overlap) + (extra > 0 ? 20 : 0),
      height: size,
      child: Stack(
        children: [
          ...shown.asMap().entries.map((e) {
            final m = e.value;
            return Positioned(
              left: e.key * (size - overlap),
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: colors.surface, width: 1.5),
                  color: colors.primaryContainer,
                ),
                alignment: Alignment.center,
                child: Text(
                  m.initials.length >= 2
                      ? m.initials.substring(0, 2)
                      : m.initials,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: colors.onPrimaryContainer,
                  ),
                ),
              ),
            );
          }),
          if (extra > 0)
            Positioned(
              left: shown.length * (size - overlap),
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: colors.surface, width: 1.5),
                  color: colors.surfaceContainerHighest,
                ),
                alignment: Alignment.center,
                child: Text(
                  '+$extra',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
