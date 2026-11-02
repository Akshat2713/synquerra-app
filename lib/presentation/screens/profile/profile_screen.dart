import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/signup/person_entity.dart';
import '../../app/app_router.dart';
import '../../blocs/profile/profile_bloc.dart';
import '../../themes/app_text_styles.dart';
import '../../themes/app_tokens.dart';
import '../../themes/colors.dart';
import '../../utils/app_icons.dart';
import '../../utils/date_time_formatter.dart';
import '../../widgets/app_motion_widgets.dart';
import '../../widgets/app_section_card.dart';
import '../../widgets/app_surfaces.dart';
import '../../widgets/async_state_view.dart';
import '../../widgets/user_avatar.dart';
import 'profile_skeleton.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    _fetch();
  }

  void _fetch() => context.read<ProfileBloc>().add(const FetchUserProfile());

  // TODO(logic): move refresh-and-wait into the bloc (a refresh event that
  // completes when loaded/error) instead of awaiting the stream in the UI.
  Future<void> _refresh() async {
    _fetch();
    await context.read<ProfileBloc>().stream.firstWhere(
      (s) => s is ProfileLoaded || s is ProfileError,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        final loaded = state is ProfileLoaded ? state : null;

        return Scaffold(
          backgroundColor: AppColors.background(context),
          appBar: AppBar(
            title: const Text('Profile'),
            actions: [
              IconButton(
                tooltip: 'Edit profile',
                icon: Icon(AppIcons.edit),
                onPressed: loaded == null
                    ? null
                    : () => AppRouter.pushEditProfile(
                        context,
                        bloc: context.read<ProfileBloc>(),
                        person: loaded.user,
                      ),
              ),
            ],
          ),
          body: AsyncStateView(
            isLoading: state is ProfileInitial || state is ProfileLoading,
            errorMessage: state is ProfileError
                ? (state.message.isEmpty
                      ? 'Something went wrong'
                      : state.message)
                : null,
            onRetry: _fetch,
            loadingWidget: const ProfileSkeleton(),
            builder: () {
              if (loaded == null) return const SizedBox.shrink();
              final user = loaded.user;

              return RefreshIndicator(
                onRefresh: _refresh,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.md,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: AppSpacing.md,
                    children: [
                      _ProfileHero(user: user).entrance(context, index: 0),
                      _PersonalCard(user: user).entrance(context, index: 1),
                      _AddressCard(user: user).entrance(context, index: 2),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

// ──────────────────────────────────────────────────────────────── hero

class _ProfileHero extends StatelessWidget {
  final PersonEntity user;
  const _ProfileHero({required this.user});

  @override
  Widget build(BuildContext context) {
    final fullName = '${user.firstName} ${user.lastName}'.trim();
    final onPrimary = AppColors.onPrimary(context);
    final pillBg = AppAlpha.withAlpha(onPrimary, AppAlpha.fill);

    final phone = user.phone ?? user.mobile;
    final city = user.city;
    final pills = <Widget>[
      if (phone != null && phone.isNotEmpty)
        InfoPill(
          label: phone,
          icon: AppIcons.phone,
          background: pillBg,
          foreground: onPrimary,
        ),
      if (city != null && city.isNotEmpty)
        InfoPill(
          label: city,
          icon: AppIcons.address,
          background: pillBg,
          foreground: onPrimary,
        ),
    ];

    return Container(
      padding: AppSpacing.lgAll,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient(context),
        borderRadius: AppRadius.lgAll,
        boxShadow: AppShadow.glow(AppColors.primary(context)),
      ),
      child: Column(
        spacing: AppSpacing.smd,
        children: [
          // Translucent ring around the avatar.
          Container(
            padding: AppSpacing.xsAll,
            decoration: BoxDecoration(shape: BoxShape.circle, color: pillBg),
            child: UserAvatar(
              name: fullName,
              photoUrl: user.profilePhoto,
              radius: AppSize.avatarLg / 2,
              maxInitials: 1,
              backgroundColor: onPrimary,
              textColor: AppColors.primary(context),
            ),
          ),
          Column(
            spacing: AppSpacing.xs,
            children: [
              Text(
                fullName.isNotEmpty ? fullName : 'User Profile',
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.titleWithColor(context, color: onPrimary),
              ),
              if (user.email != null && user.email!.isNotEmpty)
                Text(
                  user.email!,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.metaWithColor(
                    context,
                    color: AppAlpha.withAlpha(onPrimary, AppAlpha.strong),
                  ),
                ),
            ],
          ),
          if (pills.isNotEmpty)
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              alignment: WrapAlignment.center,
              children: pills,
            ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────── cards

class _PersonalCard extends StatelessWidget {
  final PersonEntity user;
  const _PersonalCard({required this.user});

  @override
  Widget build(BuildContext context) {
    // TODO(logic): gender capitalising and the phone/mobile fallback belong
    // in the entity or a presenter.
    final gender = user.gender?.capitalize();
    final birth = user.birthDate;

    return AppSectionCard(
      title: 'Personal Information',
      icon: AppIcons.person,
      background: AppColors.primary(context),
      foreground: AppColors.onPrimary(context),
      spacing: null,
      children: [
        _InfoRow(label: 'Phone', value: user.phone ?? user.mobile ?? 'N/A'),
        _InfoRow(
          label: 'Gender',
          value: gender ?? 'N/A',
          valueWidget: gender == null
              ? null
              : InfoPill(
                  label: gender,
                  background: AppColors.primaryContainer(context),
                  foreground: AppColors.onPrimaryContainer(context),
                ),
        ),
        _InfoRow(
          label: 'Birth Date',
          value: birth == null ? 'N/A' : DateTimeFormatter.formatDate(birth),
        ),
      ],
    );
  }
}

class _AddressCard extends StatelessWidget {
  final PersonEntity user;
  const _AddressCard({required this.user});

  @override
  Widget build(BuildContext context) {
    final hasAddress =
        user.address != null ||
        user.city != null ||
        user.state != null ||
        user.country != null;

    return AppSectionCard(
      title: 'Address Details',
      icon: AppIcons.address,
      background: AppColors.info,
      foreground: AppColors.onInfo,
      spacing: null,
      children: [
        if (hasAddress) ...[
          _InfoRow(label: 'Street Address', value: user.address ?? 'N/A'),
          _InfoRow(label: 'City', value: user.city ?? 'N/A'),
          _InfoRow(label: 'State', value: user.state ?? 'N/A'),
          _InfoRow(label: 'Country', value: user.country ?? 'N/A'),
          _InfoRow(label: 'Pincode', value: user.pincode ?? 'N/A'),
        ] else
          Text(
            'No address details provided',
            style: AppTextStyles.bodyWithColor(
              context,
              color: AppColors.textTertiary(context),
            ),
          ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Widget? valueWidget;

  const _InfoRow({required this.label, required this.value, this.valueWidget});

  @override
  Widget build(BuildContext context) {
    return InsetRow(
      child: Row(
        spacing: AppSpacing.md,
        children: [
          Text(label, style: AppTextStyles.bodyWithColor(context)),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child:
                  valueWidget ??
                  Text(
                    value,
                    textAlign: TextAlign.end,
                    style: AppTextStyles.bodyWithColor(
                      context,
                      color: AppColors.textPrimary(context),
                    ).copyWith(fontWeight: FontWeight.w600),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

// TODO(logic): move to utils (and search the project for a duplicate).
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }
}
