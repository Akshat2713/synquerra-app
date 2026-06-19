import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'home_detail_event.dart';
part 'home_detail_state.dart';

/// Placeholder BLoC — wire up your real repository / use-cases here.
class HomeDetailBloc extends Bloc<HomeDetailEvent, HomeDetailState> {
  HomeDetailBloc() : super(const HomeDetailInitial()) {
    on<HomeDetailLoadRequested>(_onLoad);
    on<HomeDetailRefreshRequested>(_onRefresh);
    on<HomeDetailMemberSelected>(_onMemberSelected);
  }

  // ── Placeholder members ──────────────────────────────────────────────
  static final _placeholderMembers = [
    const MemberSummary(
      id: '1',
      name: 'Priya',
      initials: 'PR',
      needsAttention: false,
    ),
    const MemberSummary(
      id: '2',
      name: 'Arjun',
      initials: 'AR',
      needsAttention: true,
    ),
    const MemberSummary(
      id: '3',
      name: 'Sara',
      initials: 'SA',
      needsAttention: false,
    ),
    const MemberSummary(
      id: '4',
      name: 'Dev',
      initials: 'DV',
      needsAttention: false,
    ),
    const MemberSummary(
      id: '5',
      name: 'Mia',
      initials: 'MI',
      needsAttention: false,
    ),
  ];

  Future<void> _onLoad(
    HomeDetailLoadRequested _,
    Emitter<HomeDetailState> emit,
  ) async {
    emit(const HomeDetailLoading());
    await _fetchAndEmit(emit, selectedId: _placeholderMembers.first.id);
  }

  Future<void> _onRefresh(
    HomeDetailRefreshRequested _,
    Emitter<HomeDetailState> emit,
  ) async {
    final current = state;
    final selectedId = current is HomeDetailLoaded
        ? current.selectedMember.summary.id
        : _placeholderMembers.first.id;
    await _fetchAndEmit(emit, selectedId: selectedId);
  }

  Future<void> _onMemberSelected(
    HomeDetailMemberSelected event,
    Emitter<HomeDetailState> emit,
  ) async {
    await _fetchAndEmit(emit, selectedId: event.memberId);
  }

  Future<void> _fetchAndEmit(
    Emitter<HomeDetailState> emit, {
    required String selectedId,
  }) async {
    try {
      // TODO: replace with real repository call
      await Future.delayed(const Duration(milliseconds: 500));

      final members = _placeholderMembers;
      final selected = members.firstWhere(
        (m) => m.id == selectedId,
        orElse: () => members.first,
      );
      final attentionCount = members.where((m) => m.needsAttention).length;

      emit(
        HomeDetailLoaded(
          members: members,
          selectedMember: MemberDetail.placeholder(selected),
          attentionCount: attentionCount,
        ),
      );
    } catch (e) {
      emit(HomeDetailError(e.toString()));
    }
  }
}
