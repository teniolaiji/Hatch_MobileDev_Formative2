import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../utils/greeting.dart';
import '../models/opportunity.dart';
import '../providers/user_providers.dart';
import '../providers/opportunity_providers.dart';
import 'package:go_router/go_router.dart';
import 'package:hatch/router/app_router.dart';

class StudentHomeScreen extends ConsumerWidget {
  const StudentHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final user = ref.watch(currentUserProvider).value;
    final opportunitiesAsync = ref.watch(opportunitiesProvider);
    final topMatch = ref.watch(topMatchProvider);

    final firstName = (user?.name ?? '').split(' ').first;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Text(greetingForNow(), style: text.bodyMedium),
            const SizedBox(height: AppSpacing.xs),
            Text(
              firstName.isEmpty ? 'Welcome' : firstName,
              style: text.displayMedium,
            ),
            const SizedBox(height: AppSpacing.xl),
            Text('Your top match', style: text.titleMedium),
            const SizedBox(height: AppSpacing.md),
            opportunitiesAsync.when(
              loading: () => const _HomeLoading(),
              error: (e, _) => const _HomeMessage(
                text: 'Could not load opportunities right now.',
              ),
              data: (_) => topMatch == null
                  ? const _HomeMessage(
                      text: 'No opportunities yet. Check back soon.',
                    )
                  : _TopMatchCard(opportunity: topMatch),
            ),
            const SizedBox(height: AppSpacing.lg),
            OutlinedButton(
              onPressed: () => context.push(Routes.discover),
              child: const Text('Browse all opportunities'),
            ),
            const SizedBox(height: AppSpacing.md),
            OutlinedButton(
              onPressed: () => context.push(Routes.applications),
              child: const Text('My applications'),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopMatchCard extends StatelessWidget {
  const _TopMatchCard({required this.opportunity});
  final Opportunity opportunity;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
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
          Text(opportunity.title, style: text.headlineMedium),
          const SizedBox(height: AppSpacing.sm),
          Text(
            opportunity.description,
            style: text.bodyMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.md),
          if (opportunity.requiredSkills.isNotEmpty)
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: opportunity.requiredSkills
                  .take(4)
                  .map((skill) => Chip(label: Text(skill)))
                  .toList(),
            ),
          const SizedBox(height: AppSpacing.md),
          Align(
            alignment: Alignment.centerLeft,
            child: ElevatedButton(
              onPressed: () =>
                  context.push(Routes.opportunityDetail, extra: opportunity),
              child: const Text('View opportunity'),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeLoading extends StatelessWidget {
  const _HomeLoading();
  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.all(AppSpacing.xl),
    child: Center(child: CircularProgressIndicator()),
  );
}

class _HomeMessage extends StatelessWidget {
  const _HomeMessage({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyMedium;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(text, style: style),
    );
  }
}
