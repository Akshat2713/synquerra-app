part of 'home_detail_bloc.dart';

abstract class HomeDetailEvent extends Equatable {
  const HomeDetailEvent();

  @override
  List<Object?> get props => [];
}

class HomeDetailLoadRequested extends HomeDetailEvent {
  const HomeDetailLoadRequested();
}

class HomeDetailRefreshRequested extends HomeDetailEvent {
  const HomeDetailRefreshRequested();
}

class HomeDetailMemberSelected extends HomeDetailEvent {
  final String memberId;
  const HomeDetailMemberSelected(this.memberId);

  @override
  List<Object?> get props => [memberId];
}
