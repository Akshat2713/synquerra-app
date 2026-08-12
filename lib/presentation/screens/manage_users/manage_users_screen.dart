import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/manage_users/manage_users_bloc.dart';
import 'add_member_screen.dart';
import 'widget/member_card.dart';

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

  Future<void> _confirmDelete(
    BuildContext context,
    String personId,
    String name,
  ) async {
    final colors = Theme.of(context).colorScheme;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remove Member'),
        content: Text(
          'Remove ${name.isEmpty ? 'this member' : name}? '
          'This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text('Remove', style: TextStyle(color: colors.error)),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<ManageUsersBloc>().add(ManageUsersDeleteRequested(personId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(title: const Text('Manage Users'), centerTitle: false),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final bloc = context.read<ManageUsersBloc>();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: bloc,
                child: const AddMemberScreen(),
              ),
            ),
          );
        },
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
          if (state is ManageUsersInitial || state is ManageUsersLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ManageUsersError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    size: 48,
                    color: colors.error,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: colors.onSurfaceVariant),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => context.read<ManageUsersBloc>().add(
                      const ManageUsersLoadRequested(),
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final loaded = state as ManageUsersLoaded;
          final members = loaded.members;

          return RefreshIndicator(
            onRefresh: () async {
              context.read<ManageUsersBloc>().add(
                const ManageUsersLoadRequested(),
              );
            },
            color: colors.primary,
            child: members.isEmpty
                ? ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.28,
                      ),
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
                        'Tap "Add Member" to add a family member.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: colors.onSurfaceVariant.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 12, bottom: 80),
                    itemCount: members.length,
                    itemBuilder: (context, index) {
                      final member = members[index];
                      final isDeleting =
                          loaded.deletingPersonId == member.personId;
                      return Opacity(
                        opacity: isDeleting ? 0.5 : 1,
                        child: MemberCard(
                          person: member,
                          onDelete: isDeleting
                              ? null
                              : () => _confirmDelete(
                                  context,
                                  member.personId,
                                  '${member.firstName} ${member.lastName}'
                                      .trim(),
                                ),
                        ),
                      );
                    },
                  ),
          );
        },
      ),
    );
  }
}
