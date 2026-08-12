part of 'manage_users_bloc.dart';

sealed class ManageUsersState extends Equatable {
  const ManageUsersState();
  @override
  List<Object?> get props => [];
}

class ManageUsersInitial extends ManageUsersState {
  const ManageUsersInitial();
}

class ManageUsersLoading extends ManageUsersState {
  const ManageUsersLoading();
}

class ManageUsersLoaded extends ManageUsersState {
  final List<PersonEntity> members;
  final bool isAdding;
  final String? deletingPersonId;
  final String? errorMessage;
  final bool? clearDeletingId;
  final bool? clearError;

  const ManageUsersLoaded({
    required this.members,
    this.isAdding = false,
    this.deletingPersonId,
    this.errorMessage,
    this.clearDeletingId,
    this.clearError,
  });

  ManageUsersLoaded copyWith({
    List<PersonEntity>? members,
    bool? isAdding,
    String? deletingPersonId,
    bool clearDeletingId = false,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ManageUsersLoaded(
      members: members ?? this.members,
      isAdding: isAdding ?? this.isAdding,
      deletingPersonId: clearDeletingId
          ? null
          : (deletingPersonId ?? this.deletingPersonId),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
    members,
    isAdding,
    deletingPersonId,
    errorMessage,
  ];
}

class ManageUsersError extends ManageUsersState {
  final String message;
  const ManageUsersError(this.message);

  @override
  List<Object?> get props => [message];
}
