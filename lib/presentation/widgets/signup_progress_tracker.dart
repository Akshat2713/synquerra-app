import 'package:flutter/material.dart';
import '../themes/app_text_styles.dart';
import '../themes/app_tokens.dart';
import '../themes/colors.dart';
import '../utils/app_icons.dart';
import 'app_surfaces.dart';

enum SignupStep { profile, security, device }

enum _StepState { done, active, pending }

class SignupProgressTracker extends StatelessWidget {
  final SignupStep currentStep;
  const SignupProgressTracker({super.key, required this.currentStep});

  _StepState _stateOf(SignupStep step) {
    if (currentStep.index > step.index) return _StepState.done;
    if (currentStep == step) return _StepState.active;
    return _StepState.pending;
  }

  @override
  Widget build(BuildContext context) {
    final profileDone = _stateOf(SignupStep.profile) == _StepState.done;

    return AppCard(
      padding: AppSpacing.smAll,
      child: Row(
        spacing: AppSpacing.sm,
        children: [
          Expanded(
            child: _StepNode(
              icon: AppIcons.person,
              title: 'Profile',
              sub: 'Personal details',
              state: _stateOf(SignupStep.profile),
            ),
          ),
          Icon(
            AppIcons.chevron,
            size: AppSize.icon,
            color: profileDone
                ? AppColors.primary(context)
                : AppColors.textTertiary(context),
          ),
          Expanded(
            child: _StepNode(
              icon: AppIcons.lock,
              title: 'Security',
              sub: 'Password setup',
              state: _stateOf(SignupStep.security),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepNode extends StatelessWidget {
  final IconData icon;
  final String title;
  final String sub;
  final _StepState state;

  const _StepNode({
    required this.icon,
    required this.title,
    required this.sub,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (state) {
      _StepState.done => (AppColors.success, AppColors.onSuccess),
      _StepState.active => (
        AppColors.primary(context),
        AppColors.onPrimary(context),
      ),
      _StepState.pending => (
        AppColors.surfaceVariant(context),
        AppColors.textSecondary(context),
      ),
    };
    final pending = state == _StepState.pending;

    return Semantics(
      label: '$title, ${state.name}',
      excludeSemantics: true,
      child: Row(
        spacing: AppSpacing.sm,
        children: [
          IconTile(
            circle: true,
            size: AppSize.avatarSm,
            iconSize: AppSize.iconSm,
            icon: state == _StepState.done ? AppIcons.selected : icon,
            background: bg,
            foreground: fg,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyWithColor(
                    context,
                    color: pending
                        ? AppColors.textSecondary(context)
                        : AppColors.textPrimary(context),
                  ).copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  sub,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.metaWithColor(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
