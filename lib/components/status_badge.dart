import 'package:flutter/material.dart';
import 'package:hatch/models/application.dart';
import 'package:hatch/theme/app_colors.dart';
import 'package:hatch/theme/app_spacing.dart';

// A small colored pill showing an application's status.
class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});
  final ApplicationStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      ApplicationStatus.submitted => ('Submitted', AppColors.ochre),
      ApplicationStatus.reviewing => ('Reviewing', AppColors.ochre),
      ApplicationStatus.accepted => ('Accepted', AppColors.primary),
      ApplicationStatus.rejected => ('Rejected', AppColors.danger),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color),
      ),
    );
  }
}