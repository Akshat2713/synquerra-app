import 'package:flutter/material.dart';
import '../../../../domain/entities/signup/person_entity.dart';
import '../../../themes/colors.dart';

class MemberCard extends StatelessWidget {
  final PersonEntity person;
  final VoidCallback? onTap;
  final VoidCallback? onUnlink;
  final VoidCallback? onDelete;

  const MemberCard({
    super.key,
    required this.person,
    this.onTap,
    this.onUnlink,
    this.onDelete,
  });

  String get _fullName {
    final name = '${person.firstName} ${person.lastName}'.trim();
    return name.isEmpty ? 'Unnamed Member' : name;
  }

  String get _initials {
    if (person.firstName.isNotEmpty && person.lastName.isNotEmpty) {
      return '${person.firstName[0]}${person.lastName[0]}'.toUpperCase();
    } else if (person.firstName.isNotEmpty) {
      return person.firstName[0].toUpperCase();
    }
    return '?';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: circularBorder(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow(context).withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: AppColors.textSecondary(context).withValues(alpha: 0.12),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.primaryContainer,
                child: Text(
                  _initials,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onPrimaryContainer(context),
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _fullName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary(context),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.phone_outlined,
                          size: 14,
                          color: AppColors.textSecondary(context),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            person.phone != null && person.phone!.isNotEmpty
                                ? person.phone!
                                : 'No phone number',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary(context),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.email_outlined,
                          size: 14,
                          color: AppColors.textSecondary(context),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            person.email != null && person.email!.isNotEmpty
                                ? person.email!
                                : 'No email address',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary(context),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Action Menu with Unlink & Delete
              if (onUnlink != null || onDelete != null)
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert_rounded,
                    color: AppColors.textSecondary(context),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onSelected: (value) {
                    if (value == 'unlink') onUnlink?.call();
                    if (value == 'delete') onDelete?.call();
                  },
                  itemBuilder: (context) => [
                    if (onUnlink != null)
                      PopupMenuItem<String>(
                        value: 'unlink',
                        child: Row(
                          children: [
                            Icon(
                              Icons.link_off_rounded,
                              color: AppColors.textSecondary(context),
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            const Text('Unlink Member'),
                          ],
                        ),
                      ),
                    if (onDelete != null)
                      PopupMenuItem<String>(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete_outline_rounded,
                              color: AppColors.danger,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Delete Member',
                              style: TextStyle(color: AppColors.danger),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  BorderRadius circularBorder(double radius) => BorderRadius.circular(radius);
}
