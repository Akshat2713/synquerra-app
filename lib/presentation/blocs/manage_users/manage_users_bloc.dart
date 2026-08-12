import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/utils/app_logger.dart';
import '../../../domain/entities/signup/person_entity.dart';
import '../../../domain/usecases/relationship/get_relationship_list_usecase.dart';
import '../../../domain/usecases/relationship/create_relationship_usecase.dart';
import '../../../domain/usecases/signup/create_person_usecase.dart';
import '../../../domain/usecases/signup/delete_person_usecase.dart';

part 'manage_users_event.dart';
part 'manage_users_state.dart';

class ManageUsersBloc extends Bloc<ManageUsersEvent, ManageUsersState> {
  final GetRelationshipListUseCase _getRelationshipListUseCase;
  final CreatePersonUseCase _createPersonUseCase;
  final CreateRelationshipUseCase _createRelationshipUseCase;
  final DeletePersonUseCase _deletePersonUseCase;
  final UserHolder _userHolder;

  ManageUsersBloc({
    required GetRelationshipListUseCase getRelationshipListUseCase,
    required CreatePersonUseCase createPersonUseCase,
    required CreateRelationshipUseCase createRelationshipUseCase,
    required DeletePersonUseCase deletePersonUseCase,
    required UserHolder userHolder,
  }) : _getRelationshipListUseCase = getRelationshipListUseCase,
       _createPersonUseCase = createPersonUseCase,
       _createRelationshipUseCase = createRelationshipUseCase,
       _deletePersonUseCase = deletePersonUseCase,
       _userHolder = userHolder,
       super(const ManageUsersInitial()) {
    on<ManageUsersLoadRequested>(_onLoad);
    on<ManageUsersAddRequested>(_onAdd);
    on<ManageUsersDeleteRequested>(_onDelete);
  }

  List<PersonEntity> _currentMembers() {
    final s = state;
    return s is ManageUsersLoaded ? s.members : const [];
  }

  Future<void> _onLoad(
    ManageUsersLoadRequested event,
    Emitter<ManageUsersState> emit,
  ) async {
    emit(const ManageUsersLoading());
    final personId = _userHolder.user?.personId;
    if (personId == null) {
      emit(const ManageUsersError('User not found. Please log in again.'));
      return;
    }
    final result = await _getRelationshipListUseCase(personId);
    result.fold(
      (failure) {
        AppLogger.d(
          'ManageUsersBloc',
          'Relationships fetch failed: ${failure.message}',
        );
        emit(ManageUsersError(failure.userMessage));
      },
      (relationships) {
        final members = relationships
            .map((r) => r.personB)
            .whereType<PersonEntity>()
            .toList();
        AppLogger.d('ManageUsersBloc', 'Loaded ${members.length} members');
        emit(ManageUsersLoaded(members: members));
      },
    );
  }

  Future<void> _onAdd(
    ManageUsersAddRequested event,
    Emitter<ManageUsersState> emit,
  ) async {
    final currentUserId = _userHolder.user?.personId;
    if (currentUserId == null) {
      emit(const ManageUsersError('User not found. Please log in again.'));
      return;
    }
    final baseMembers = _currentMembers();
    emit(ManageUsersLoaded(members: baseMembers, isAdding: true));

    final personResult = await _createPersonUseCase(
      CreatePersonParams(
        firstName: event.firstName,
        lastName: event.lastName,
        email: event.email,
        phone: event.phone,
        birthDate: event.birthDate,
        gender: event.gender,
        address: event.address,
        city: event.city,
        state: event.state,
        country: event.country,
        pincode: event.pincode,
        saveSignupProgress: false,
      ),
    );

    await personResult.fold(
      (failure) async {
        AppLogger.d(
          'ManageUsersBloc',
          'Create person failed: ${failure.message}',
        );
        emit(
          ManageUsersLoaded(
            members: baseMembers,
            isAdding: false,
            errorMessage: failure.userMessage,
          ),
        );
      },
      (newPerson) async {
        final relResult = await _createRelationshipUseCase(
          personAId: currentUserId,
          personBId: newPerson.personId,
          relationshipType: event.relationshipType,
        );
        relResult.fold(
          (failure) {
            AppLogger.d(
              'ManageUsersBloc',
              'Create relationship failed: ${failure.message}',
            );
            // Person exists server-side even though linking failed —
            // show them, but surface the error so the user knows to retry.
            emit(
              ManageUsersLoaded(
                members: [...baseMembers, newPerson],
                isAdding: false,
                errorMessage: failure.userMessage,
              ),
            );
          },
          (_) {
            emit(
              ManageUsersLoaded(
                members: [...baseMembers, newPerson],
                isAdding: false,
                clearError: true,
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _onDelete(
    ManageUsersDeleteRequested event,
    Emitter<ManageUsersState> emit,
  ) async {
    final baseMembers = _currentMembers();
    emit(
      ManageUsersLoaded(members: baseMembers, deletingPersonId: event.personId),
    );

    final result = await _deletePersonUseCase(event.personId);
    result.fold(
      (failure) {
        AppLogger.d('ManageUsersBloc', 'Delete failed: ${failure.message}');
        emit(
          ManageUsersLoaded(
            members: baseMembers,
            clearDeletingId: true,
            errorMessage: failure.userMessage,
          ),
        );
      },
      (_) {
        emit(
          ManageUsersLoaded(
            members: baseMembers
                .where((m) => m.personId != event.personId)
                .toList(),
            clearDeletingId: true,
            clearError: true,
          ),
        );
      },
    );
  }
}
