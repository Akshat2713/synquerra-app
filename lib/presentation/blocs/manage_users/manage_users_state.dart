// lib/presentation/blocs/manage_users/manage_users_state.dart

part of 'manage_users_bloc.dart';

sealed class ManageUsersState extends BaseState {
  const ManageUsersState();
}

class ManageUsersInitial extends ManageUsersState {
  const ManageUsersInitial();
}

class ManageUsersLoading extends ManageUsersState with LoadingState {
  const ManageUsersLoading();
}

class MemberItem extends Equatable {
  final String relationshipId;
  final PersonEntity person;

  const MemberItem({required this.relationshipId, required this.person});

  @override
  List<Object?> get props => [relationshipId, person];
}

class ManageUsersLoaded extends ManageUsersState {
  final List<MemberItem> members;
  final bool isProcessing;
  final String? errorMessage;

  const ManageUsersLoaded({
    required this.members,
    this.isProcessing = false,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [members, isProcessing, errorMessage];
}

class ManageUsersError extends ManageUsersState with ErrorState {
  @override
  final String message;

  const ManageUsersError(this.message);

  @override
  List<Object?> get props => [message];
}
