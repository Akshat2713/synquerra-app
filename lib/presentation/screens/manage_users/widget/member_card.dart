import 'package:flutter/material.dart';

import '../../../../domain/entities/signup/person_entity.dart';

class MemberCard extends StatelessWidget {
  final PersonEntity person;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const MemberCard({
    super.key,
    required this.person,
    this.onTap,
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
    final colors = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: colors.onSurfaceVariant.withValues(alpha: 0.12),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Avatar with Initials
              CircleAvatar(
                radius: 24,
                backgroundColor: colors.primaryContainer,
                child: Text(
                  _initials,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: colors.onPrimaryContainer,
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Info Column (Name, Email, Phone)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _fullName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: colors.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),

                    // Phone Row
                    Row(
                      children: [
                        Icon(
                          Icons.phone_outlined,
                          size: 14,
                          color: colors.onSurfaceVariant,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            person.phone != null && person.phone!.isNotEmpty
                                ? person.phone!
                                : 'No phone number',
                            style: TextStyle(
                              fontSize: 13,
                              color: colors.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Email Row
                    Row(
                      children: [
                        Icon(
                          Icons.email_outlined,
                          size: 14,
                          color: colors.onSurfaceVariant,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            person.email != null && person.email!.isNotEmpty
                                ? person.email!
                                : 'No email address',
                            style: TextStyle(
                              fontSize: 13,
                              color: colors.onSurfaceVariant,
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

              // Optional Action Menu (Edit/Delete)
              if (onDelete != null)
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert_rounded,
                    color: colors.onSurfaceVariant,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onSelected: (value) {
                    if (value == 'delete') onDelete?.call();
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem<String>(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_outline_rounded,
                            color: colors.error,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Remove Member',
                            style: TextStyle(color: colors.error),
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
}
