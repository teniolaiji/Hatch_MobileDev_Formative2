import 'package:flutter/material.dart';
import 'package:hatch/models/opportunity.dart';
import 'package:hatch/theme/app_colors.dart';
import 'package:hatch/theme/app_spacing.dart';

// A single opportunity as a tappable card in a feed.
class OpportunityCard extends StatelessWidget {
  const OpportunityCard({super.key, required this.opportunity, this.onTap});

  final Opportunity opportunity;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(opportunity.startupName, style: text.labelLarge),
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
                    .map((s) => Chip(label: Text(s)))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}