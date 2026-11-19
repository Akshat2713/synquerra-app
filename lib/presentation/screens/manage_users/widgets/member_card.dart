import 'package:flutter/material.dart';
import '../../../../domain/entities/relationship/related_user_entity.dart';
import '../../../themes/app_text_styles.dart';
import '../../../themes/app_tokens.dart';
import '../../../themes/colors.dart';
import '../../../utils/app_icons.dart';
import '../../../widgets/app_surfaces.dart';
import '../../../widgets/user_avatar.dart';

enum _MemberAction { unlink, delete }

class MemberCard extends StatelessWidget {
  final RelatedUserEntity person;
  final VoidCallback? onUnlink;
  final VoidCallback? onDelete;

  const MemberCard({
    super.key,
    required this.person,
    this.onUnlink,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final name = person.fullName.isEmpty ? 'Unnamed Member' : person.fullName;
    final phone = (person.mobile ?? '').isNotEmpty
        ? person.mobile!
        : 'No phone number';
    final email = (person.email ?? '').isNotEmpty
        ? person.email!
        : (person.uniqueId.isNotEmpty
              ? 'ID: ${person.uniqueId}'
              : 'No email address');

    return AppCard(
      child: Row(
        spacing: AppSpacing.md,
        children: [
          UserAvatar(
            name: person.fullName,
            photoUrl: person.profilePhoto,
            radius: AppSize.tapTarget / 2,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: AppSpacing.xs,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.sectionWithColor(context),
                ),
                _DetailLine(icon: AppIcons.phone, text: phone),
                _DetailLine(icon: AppIcons.email, text: email),
              ],
            ),
          ),
          if (onUnlink != null || onDelete != null)
            PopupMenuButton<_MemberAction>(
              tooltip: 'Member actions',
              icon: Icon(
                AppIcons.more,
                color: AppColors.textSecondary(context),
              ),
              onSelected: (a) => switch (a) {
                _MemberAction.unlink => onUnlink?.call(),
                _MemberAction.delete => onDelete?.call(),
              },
              itemBuilder: (_) => [
                if (onUnlink != null)
                  PopupMenuItem(
                    value: _MemberAction.unlink,
                    child: _MenuLabel(
                      icon: AppIcons.unlink,
                      label: 'Unlink Member',
                      iconColor: AppColors.textSecondary(context),
                    ),
                  ),
                if (onDelete != null)
                  const PopupMenuItem(
                    value: _MemberAction.delete,
                    child: _MenuLabel(
                      icon: AppIcons.delete,
                      label: 'Delete Member',
                      iconColor: AppColors.danger,
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _DetailLine extends StatelessWidget {
  final IconData icon;
  final String text;
  const _DetailLine({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: AppSpacing.xs,
      children: [
        Icon(
          icon,
          size: AppSize.iconSm,
          color: AppColors.textSecondary(context),
        ),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.metaWithColor(context),
          ),
        ),
      ],
    );
  }
}

class _MenuLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;
  const _MenuLabel({
    required this.icon,
    required this.label,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: AppSpacing.smd,
      children: [
        Icon(icon, size: AppSize.icon, color: iconColor),
        Text(label),
      ],
    );
  }
}
