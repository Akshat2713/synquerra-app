part of 'home_detail_bloc.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Data models  — replace with your real domain models
// ─────────────────────────────────────────────────────────────────────────────

class MemberSummary {
  final String id;
  final String name;

  /// Initials shown in avatar when no photo
  final String initials;

  /// URL for a real avatar photo; null → show initials
  final String? avatarUrl;

  final bool needsAttention;

  const MemberSummary({
    required this.id,
    required this.name,
    required this.initials,
    this.avatarUrl,
    required this.needsAttention,
  });
}

enum RiskLevel { low, medium, high }

class ScheduleEntry {
  final String time;
  final String label;
  const ScheduleEntry({required this.time, required this.label});
}

class MemberDetail {
  final MemberSummary summary;
  final String statusLabel;
  final String gender;
  final String verifiedAgo;
  final String locationLabel;
  final String locationSubtitle;
  final int safeStreakDays;
  final bool todayLooksNormal;
  final List<ScheduleEntry> todaySchedule;
  final String insightText;
  final RiskLevel riskLevel;

  const MemberDetail({
    required this.summary,
    required this.statusLabel,
    required this.gender,
    required this.verifiedAgo,
    required this.locationLabel,
    required this.locationSubtitle,
    required this.safeStreakDays,
    required this.todayLooksNormal,
    required this.todaySchedule,
    required this.insightText,
    required this.riskLevel,
  });

  // ── Placeholder factory ──────────────────────────────────────────────
  static MemberDetail placeholder(MemberSummary s) => MemberDetail(
    summary: s,
    gender: 'female',
    statusLabel: 'All good right now',
    verifiedAgo: '2 min ago',
    locationLabel: 'At School',
    locationSubtitle: 'Arrived 8:42 AM',
    safeStreakDays: 14,
    todayLooksNormal: true,
    todaySchedule: [
      const ScheduleEntry(time: '18:00', label: 'Evening routine'),
    ],
    insightText: 'Likely on time',
    riskLevel: RiskLevel.low,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// States
// ─────────────────────────────────────────────────────────────────────────────

abstract class HomeDetailState extends Equatable {
  const HomeDetailState();

  @override
  List<Object?> get props => [];
}

class HomeDetailInitial extends HomeDetailState {
  const HomeDetailInitial();
}

class HomeDetailLoading extends HomeDetailState {
  const HomeDetailLoading();
}

class HomeDetailLoaded extends HomeDetailState {
  final List<MemberSummary> members;
  final MemberDetail selectedMember;
  final int attentionCount;

  const HomeDetailLoaded({
    required this.members,
    required this.selectedMember,
    required this.attentionCount,
  });

  @override
  List<Object?> get props => [members, selectedMember, attentionCount];
}

class HomeDetailError extends HomeDetailState {
  final String message;
  const HomeDetailError(this.message);

  @override
  List<Object?> get props => [message];
}
