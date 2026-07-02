import 'package:flutter/material.dart';

enum SignupStep { profile, security, device }

class SignupProgressTracker extends StatelessWidget {
  final SignupStep currentStep;

  const SignupProgressTracker({super.key, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: _buildStepNode(
            context,
            icon: Icons.person_outline,
            title: 'Profile',
            sub: 'Personal details',
            isActive: currentStep == SignupStep.profile,
            isDone: currentStep.index > SignupStep.profile.index,
          ),
        ),
        _buildDivider(
          colors,
          isCompleted: currentStep.index > SignupStep.profile.index,
        ),
        Expanded(
          child: _buildStepNode(
            context,
            icon: Icons.lock_outline,
            title: 'Security',
            sub: 'Password setup',
            isActive: currentStep == SignupStep.security,
            isDone: currentStep.index > SignupStep.security.index,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider(ColorScheme colors, {required bool isCompleted}) {
    return SizedBox(
      width: 20,
      child: Divider(
        color: isCompleted ? colors.primary : colors.outlineVariant,
        thickness: 1,
      ),
    );
  }

  Widget _buildStepNode(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String sub,
    required bool isActive,
    required bool isDone,
  }) {
    final colors = Theme.of(context).colorScheme;
    final accentColor = isActive || isDone
        ? colors.primary
        : colors.onSurfaceVariant.withOpacity(0.4);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: isActive || isDone
              ? colors.primary.withOpacity(0.1)
              : colors.surfaceContainerHighest,
          child: Icon(
            isDone ? Icons.check_rounded : icon,
            color: accentColor,
            size: 16,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: isActive || isDone
                ? colors.onSurface
                : colors.onSurfaceVariant,
          ),
        ),
        Text(
          sub,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant),
        ),
      ],
    );
  }
}
