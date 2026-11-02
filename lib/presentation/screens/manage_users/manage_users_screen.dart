import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/manage_users/manage_users_bloc.dart';
import '../../themes/app_tokens.dart';
import '../../themes/colors.dart';
import '../../utils/app_icons.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_empty_state.dart';
import '../../widgets/app_motion_widgets.dart';
import '../../widgets/app_overlays.dart';
import '../../widgets/async_state_view.dart';
import 'widgets/link_member_by_phone_screen.dart';
import 'widgets/member_card.dart';

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  // TODO(logic): the bloc has no success signal. Move this into the bloc
  // (e.g. a `successMessage` on ManageUsersLoaded) and drop this field.
  String? _pendingSuccess;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() =>
      context.read<ManageUsersBloc>().add(const ManageUsersLoadRequested());

  Future<void> _confirmUnlink(String relationshipId, String name) async {
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
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Unlink'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      _pendingSuccess = 'Member unlinked';
      context.read<ManageUsersBloc>().add(
        ManageUsersUnlinkRequested(relationshipId),
      );
    }
  }

  Future<void> _confirmDelete(String personId, String name) async {
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
          AppButton(
            label: 'Delete',
            fullWidth: false,
            backgroundColor: AppColors.danger,
            foregroundColor: AppColors.onDanger,
            onPressed: () => Navigator.pop(dialogContext, true),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      _pendingSuccess = 'Member deleted';
      context.read<ManageUsersBloc>().add(
        ManageUsersDeletePersonRequested(personId),
      );
    }
  }

  // TODO(logic): onRefresh should await the bloc (see ProfileScreen._refresh).
  Widget _refreshable(Widget Function(BuildContext) child) => RefreshIndicator(
    onRefresh: () async => _reload(),
    child: Builder(builder: child),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Users')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => LinkMemberByPhoneBottomSheet.show(context),
        icon: Icon(AppIcons.personAdd),
        label: const Text('Add Member'),
      ),
      body: BlocConsumer<ManageUsersBloc, ManageUsersState>(
        // Only reacts to results of unlink/delete started from this screen.
        // Link and add report their own results.
        listenWhen: (p, c) =>
            c is ManageUsersError ||
            (c is ManageUsersLoaded &&
                (c.errorMessage != null || p is ManageUsersLoading)),
        listener: (context, state) {
          final pending = _pendingSuccess;
          if (pending == null) return;
          if (state is ManageUsersError) {
            _pendingSuccess = null;
            return;
          }
          if (state is! ManageUsersLoaded) return;
          _pendingSuccess = null;
          final error = state.errorMessage;
          if (error != null) {
            AppSnackBar.error(context, error);
          } else {
            AppSnackBar.success(context, pending);
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
            onRetry: _reload,
            emptyWidget: LayoutBuilder(
              builder: (context, box) => _refreshable(
                (_) => SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: box.maxHeight),
                    child: Center(
                      child: AppEmptyState(
                        icon: AppIcons.people,
                        title: 'No members added yet',
                        message:
                            'Tap "Add Member" to link or create a family member.',
                      ),
                    ),
                  ),
                ),
              ),
            ),
            builder: () => _refreshable(
              (_) => SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                // Bottom padding keeps the last card clear of the FAB.
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSize.tapTarget + AppSpacing.xl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: AppSpacing.md,
                  children: [
                    for (var i = 0; i < members.length; i++)
                      MemberCard(
                        person: members[i].person,
                        onUnlink: isProcessing
                            ? null
                            : () => _confirmUnlink(
                                members[i].person.id,
                                members[i].person.fullName,
                              ),
                        onDelete: isProcessing
                            ? null
                            : () => _confirmDelete(
                                members[i].person.id,
                                members[i].person.fullName,
                              ),
                      ).entrance(context, index: i),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
