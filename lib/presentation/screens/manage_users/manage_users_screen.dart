// lib/presentation/screens/manage_users/manage_users_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/manage_users/manage_users_bloc.dart';
import '../../widgets/async_state_view.dart';
import 'widgets/link_member_by_phone_screen.dart';
import 'widgets/member_card.dart';

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ManageUsersBloc>().add(const ManageUsersLoadRequested());
  }

  Future<void> _confirmUnlink(
    BuildContext context,
    String relationshipId,
    String name,
  ) async {
    final colors = Theme.of(context).colorScheme;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Unlink Member'),
        content: Text(
          'Unlink ${name.isEmpty ? 'this member' : name}? '
          'They will be removed from your linked network.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text('Unlink', style: TextStyle(color: colors.primary)),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<ManageUsersBloc>().add(
        ManageUsersUnlinkRequested(relationshipId),
      );
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    String personId,
    String name,
  ) async {
    final colors = Theme.of(context).colorScheme;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Member'),
        content: Text(
          'Permanently delete ${name.isEmpty ? 'this member' : name}? '
          'This action cannot be undone and deletes all associated records.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text('Delete', style: TextStyle(color: colors.error)),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<ManageUsersBloc>().add(
        ManageUsersDeletePersonRequested(personId),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(title: const Text('Manage Users'), centerTitle: false),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => LinkMemberByPhoneBottomSheet.show(context),
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text(
          'Add Member',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: BlocConsumer<ManageUsersBloc, ManageUsersState>(
        listener: (context, state) {
          if (state is ManageUsersLoaded && state.errorMessage != null) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: colors.error,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
          }
        },
        builder: (context, state) {
          final isLoading =
              state is ManageUsersInitial || state is ManageUsersLoading;
          final errorMessage = state is ManageUsersError ? state.message : null;
          final members = state is ManageUsersLoaded
              ? state.members
              : <MemberItem>[];
          final isProcessing = state is ManageUsersLoaded
              ? state.isProcessing
              : false;

          return AsyncStateView(
            isLoading: isLoading,
            errorMessage: errorMessage,
            isEmpty: members.isEmpty,
            onRetry: () => context.read<ManageUsersBloc>().add(
              const ManageUsersLoadRequested(),
            ),
            emptyWidget: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.28),
                Icon(
                  Icons.people_outline_rounded,
                  size: 56,
                  color: colors.onSurfaceVariant.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 12),
                Text(
                  'No members added yet.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tap "Add Member" to link or create a family member.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: colors.onSurfaceVariant.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
            builder: () => RefreshIndicator(
              onRefresh: () async {
                context.read<ManageUsersBloc>().add(
                  const ManageUsersLoadRequested(),
                );
              },
              color: colors.primary,
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 12, bottom: 80),
                itemCount: members.length,
                itemBuilder: (context, index) {
                  final member = members[index];
                  final fullName =
                      '${member.person.firstName} ${member.person.lastName}'
                          .trim();

                  return MemberCard(
                    person: member.person,
                    onUnlink: isProcessing
                        ? null
                        : () => _confirmUnlink(
                            context,
                            member.relationshipId,
                            fullName,
                          ),
                    onDelete: isProcessing
                        ? null
                        : () => _confirmDelete(
                            context,
                            member.person.personId,
                            fullName,
                          ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
