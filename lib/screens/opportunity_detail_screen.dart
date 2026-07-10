import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hatch/models/opportunity.dart';
import 'package:hatch/theme/app_colors.dart';
import 'package:hatch/theme/app_spacing.dart';

class OpportunityDetailScreen extends ConsumerWidget {
  const OpportunityDetailScreen({super.key, required this.opportunity});

  final Opportunity opportunity;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Text(opportunity.startupName, style: text.labelLarge),
            const SizedBox(height: AppSpacing.xs),
            Text(opportunity.title, style: text.displayMedium),
            const SizedBox(height: AppSpacing.lg),

            Text('About this role', style: text.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            Text(opportunity.description, style: text.bodyLarge),

            if (opportunity.requiredSkills.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xl),
              Text('Skills needed', style: text.titleMedium),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: opportunity.requiredSkills
                    .map((s) => Chip(label: Text(s)))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: ElevatedButton(
          onPressed: () {},
          child: const Text('Apply for this role'),
        ),
      ),
    );
  }
}