import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:synquerra/domain/usecases/relationship/search_person_by_phone_usecase.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/utils/app_logger.dart';
import '../../../domain/entities/relationship/related_user_entity.dart';
// import '../../../domain/entities/relationship/relationship_entity.dart';
import '../../../domain/entities/signup/person_entity.dart';
import '../../../domain/usecases/relationship/create_relationship_usecase.dart';
import '../../../domain/usecases/relationship/delete_relationship_usecase.dart';
import '../../../domain/usecases/relationship/get_relationship_list_usecase.dart';
import '../../../domain/usecases/signup/create_person_usecase.dart';
import '../../../domain/usecases/signup/delete_person_usecase.dart';
import '../base/base_state.dart';

part 'manage_users_event.dart';
part 'manage_users_state.dart';

const bool kEnableDeletePerson = true;

class ManageUsersBloc extends Bloc<ManageUsersEvent, ManageUsersState> {
  final GetRelationshipListUseCase _getRelationshipListUseCase;
  final CreatePersonUseCase _createPersonUseCase;
  final CreateRelationshipUseCase _createRelationshipUseCase;
  final SearchPersonByPhoneUseCase _searchPersonByPhoneUseCase;
  final DeletePersonUseCase _deletePersonUseCase;
  final UnlinkRelationshipUseCase _unlinkRelationshipUseCase;
  final UserHolder _userHolder;

  ManageUsersBloc({
    required GetRelationshipListUseCase getRelationshipListUseCase,
    required CreatePersonUseCase createPersonUseCase,
    required CreateRelationshipUseCase createRelationshipUseCase,
    required SearchPersonByPhoneUseCase searchPersonByPhoneUseCase,
    required DeletePersonUseCase deletePersonUseCase,
    required UnlinkRelationshipUseCase unlinkRelationshipUseCase,
    required UserHolder userHolder,
  }) : _getRelationshipListUseCase = getRelationshipListUseCase,
       _createPersonUseCase = createPersonUseCase,
       _createRelationshipUseCase = createRelationshipUseCase,
       _searchPersonByPhoneUseCase = searchPersonByPhoneUseCase,
       _deletePersonUseCase = deletePersonUseCase,
       _unlinkRelationshipUseCase = unlinkRelationshipUseCase,
       _userHolder = userHolder,
       super(const ManageUsersInitial()) {
    on<ManageUsersLoadRequested>(_onLoad);
    on<ManageUsersAddRequested>(_onAdd);
    on<ManageUsersSearchByPhoneRequested>(_onSearchByPhone);
    on<ManageUsersConfirmLinkRequested>(_onConfirmLink);
    on<ManageUsersClearFoundPerson>(_onClearFoundPerson);
    on<ManageUsersDeletePersonRequested>(_onDeletePerson);
    on<ManageUsersUnlinkRequested>(_onUnlink);
  }

  List<MemberItem> _currentMembers() {
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
            .where((r) => r.relatedUser != null)
            .map(
              (r) => MemberItem(
                relationshipId: r.relatedUserId,
                person: r.relatedUser!,
              ),
            )
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
    emit(ManageUsersLoaded(members: baseMembers, isProcessing: true));

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
            errorMessage: failure.userMessage,
          ),
        );
      },
      (newPerson) async {
        final relResult = await _createRelationshipUseCase(
          relatedUserId: newPerson.id,
          relationshipType: event.relationshipType,
        );

        await relResult.fold((failure) async {
          AppLogger.d(
            'ManageUsersBloc',
            'Create relationship failed: ${failure.message}',
          );
          emit(
            ManageUsersLoaded(
              members: baseMembers,
              errorMessage: failure.userMessage,
            ),
          );
        }, (_) async => add(const ManageUsersLoadRequested()));
      },
    );
  }

  Future<void> _onSearchByPhone(
    ManageUsersSearchByPhoneRequested event,
    Emitter<ManageUsersState> emit,
  ) async {
    final baseMembers = _currentMembers();
    emit(ManageUsersLoaded(members: baseMembers, isSearching: true));
    final result = await _searchPersonByPhoneUseCase(event.phoneNumber);
    result.fold(
      (failure) => emit(
        ManageUsersLoaded(
          members: baseMembers,
          errorMessage: failure.userMessage,
        ),
      ),
      (person) =>
          emit(ManageUsersLoaded(members: baseMembers, foundPerson: person)),
    );
  }

  Future<void> _onConfirmLink(
    ManageUsersConfirmLinkRequested event,
    Emitter<ManageUsersState> emit,
  ) async {
    final s = state;
    if (s is! ManageUsersLoaded || s.foundPerson == null) return;
    final baseMembers = s.members;
    final foundPerson = s.foundPerson!;
    emit(
      ManageUsersLoaded(
        members: baseMembers,
        foundPerson: foundPerson,
        isProcessing: true,
      ),
    );
    final result = await _createRelationshipUseCase(
      relatedUserId: foundPerson.id,
      relationshipType: event.relationshipType,
    );
    await result.fold((failure) async {
      emit(
        ManageUsersLoaded(
          members: baseMembers,
          foundPerson: foundPerson,
          errorMessage: failure.userMessage,
        ),
      );
    }, (_) async => add(const ManageUsersLoadRequested()));
  }

  void _onClearFoundPerson(
    ManageUsersClearFoundPerson event,
    Emitter<ManageUsersState> emit,
  ) {
    emit(ManageUsersLoaded(members: _currentMembers()));
  }

  Future<void> _onDeletePerson(
    ManageUsersDeletePersonRequested event,
    Emitter<ManageUsersState> emit,
  ) async {
    if (!kEnableDeletePerson) return;
    final baseMembers = _currentMembers();
    emit(ManageUsersLoaded(members: baseMembers, isProcessing: true));

    final result = await _deletePersonUseCase(event.personId);

    await result.fold((failure) async {
      AppLogger.d(
        'ManageUsersBloc',
        'Delete person failed: ${failure.message}',
      );
      emit(
        ManageUsersLoaded(
          members: baseMembers,
          errorMessage: failure.userMessage,
        ),
      );
    }, (_) async => add(const ManageUsersLoadRequested()));
  }

  Future<void> _onUnlink(
    ManageUsersUnlinkRequested event,
    Emitter<ManageUsersState> emit,
  ) async {
    final baseMembers = _currentMembers();
    emit(ManageUsersLoaded(members: baseMembers, isProcessing: true));

    final result = await _unlinkRelationshipUseCase(event.relationshipId);

    await result.fold((failure) async {
      AppLogger.d('ManageUsersBloc', 'Unlink failed: ${failure.message}');
      emit(
        ManageUsersLoaded(
          members: baseMembers,
          isProcessing: false,
          errorMessage: failure.userMessage,
        ),
      );
    }, (_) async => add(const ManageUsersLoadRequested()));
  }
}
