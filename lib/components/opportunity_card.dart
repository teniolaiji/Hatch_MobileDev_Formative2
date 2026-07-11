import 'package:flutter/material.dart';
import 'package:hatch/components/verified_badge.dart';
import 'package:hatch/models/opportunity.dart';
import 'package:hatch/theme/app_colors.dart';
import 'package:hatch/theme/app_spacing.dart';

class _SkillPill extends StatelessWidget {
  const _SkillPill({required this.skill});
  final String skill;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Text(
        skill,
        style: Theme.of(context)
            .textTheme
            .labelSmall
            ?.copyWith(color: AppColors.stone),
      ),
    );
  }
}

// A single opportunity as a tappable card in a feed.
class OpportunityCard extends StatelessWidget {
  const OpportunityCard({
    super.key,
    required this.opportunity,
    this.onTap,
    this.score,
    this.isSaved = false,
    this.onToggleSave,
    this.showExpired = false,
  });

  final Opportunity opportunity;
  final VoidCallback? onTap;
  final int? score;
  final bool isSaved;
  final VoidCallback? onToggleSave;
  /// When true the card is visually muted and shows a "Closed" badge.
  /// Callers opt in — students never see expired cards; founders do.
  final bool showExpired;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final expired = showExpired && opportunity.isExpired;

    return Opacity(
      opacity: expired ? 0.55 : 1.0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: expired ? AppColors.border : AppColors.border,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(opportunity.startupName,
                              style: text.labelLarge,
                              overflow: TextOverflow.ellipsis),
                        ),
                        VerifiedBadge(show: opportunity.startupVerified),
                      ],
                    ),
                  ),
                  // Closed badge takes priority over match score
                  if (expired)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.stone.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(AppRadius.xl),
                      ),
                      child: Text(
                        'Closed',
                        style: text.labelSmall
                            ?.copyWith(color: AppColors.taupe),
                      ),
                    )
                  else if (score != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.navy.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(AppRadius.xl),
                      ),
                      child: Text(
                        '$score% match',
                        style: text.labelSmall
                            ?.copyWith(color: AppColors.navy),
                      ),
                    ),
                  if (onToggleSave != null && !expired) ...[
                    const SizedBox(width: AppSpacing.xs),
                    GestureDetector(
                      onTap: onToggleSave,
                      child: Icon(
                        isSaved ? Icons.bookmark : Icons.bookmark_border,
                        size: 20,
                        color: isSaved ? AppColors.navy : AppColors.stone,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(opportunity.title, style: text.titleLarge),
              const SizedBox(height: AppSpacing.sm),
              Text(
                opportunity.description,
                style: text.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (opportunity.requiredSkills.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: opportunity.requiredSkills
                      .take(4)
                      .map((s) => _SkillPill(skill: s))
                      .toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}