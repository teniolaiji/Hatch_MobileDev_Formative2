import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hatch/components/category_row.dart';
import 'package:hatch/components/opportunity_card.dart';
import 'package:hatch/models/opportunity.dart';
import 'package:hatch/providers/opportunity_providers.dart';
import 'package:hatch/providers/user_providers.dart';
import 'package:hatch/router/app_router.dart';
import 'package:hatch/theme/app_colors.dart';
import 'package:hatch/theme/app_spacing.dart';
import 'package:hatch/utils/greeting.dart';

class StudentHomeScreen extends ConsumerWidget {
  const StudentHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final user = ref.watch(currentUserProvider).value;
    final opportunitiesAsync = ref.watch(opportunitiesProvider);
    final byCategory = ref.watch(opportunitiesByCategoryProvider);
    final topMatch = ref.watch(topMatchProvider);
    final firstName = (user?.name ?? '').split(' ').first;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Header band
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.xl,
                  AppSpacing.lg, AppSpacing.xl),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(AppRadius.xl),
                  bottomRight: Radius.circular(AppRadius.xl),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(greetingForNow(),
                      style: text.bodyMedium
                          ?.copyWith(color: AppColors.onPrimary.withValues(alpha: 0.8))),
                  const SizedBox(height: AppSpacing.xs),
                  Text(firstName.isEmpty ? 'Welcome' : firstName,
                      style: text.displayMedium
                          ?.copyWith(color: AppColors.onPrimary)),
                  const SizedBox(height: AppSpacing.sm),
                  Text('Find your next micro-internship.',
                      style: text.bodyLarge
                          ?.copyWith(color: AppColors.onPrimary.withValues(alpha: 0.85))),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.lg),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Text('Browse by category', style: text.titleMedium),
            ),
            const SizedBox(height: AppSpacing.md),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: CategoryRow(),
            ),

            const SizedBox(height: AppSpacing.xl),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Text('Your top match', style: text.titleMedium),
            ),
            const SizedBox(height: AppSpacing.md),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: opportunitiesAsync.when(
                loading: () => const _Loading(),
                error: (e, _) => const _Message(text: 'Could not load right now.'),
                data: (_) => topMatch == null
                    ? const _Message(text: 'No opportunities yet.')
                    : _TopMatchCard(
                        opportunity: topMatch,
                        onView: () => context.push(Routes.opportunityDetail,
                            extra: topMatch),
                      ),
              ),
            ),

            const SizedBox(height: AppSpacing.xl),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Text('Recent opportunities', style: text.titleMedium),
            ),
            const SizedBox(height: AppSpacing.md),
            ...byCategory.take(4).map((o) => Padding(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.md),
                  child: OpportunityCard(
                    opportunity: o,
                    onTap: () => context.push(Routes.opportunityDetail, extra: o),
                  ),
                )),
            if (byCategory.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: _Message(text: 'Nothing in this category yet.'),
              ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}

class _TopMatchCard extends StatelessWidget {
  const _TopMatchCard({required this.opportunity, required this.onView});
  final Opportunity opportunity;
  final VoidCallback onView;

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
          Row(
            children: [
              Text(opportunity.startupName, style: text.labelLarge),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                decoration: BoxDecoration(
                  color: AppColors.highlight.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Text('Top pick',
                    style: text.labelSmall
                        ?.copyWith(color: AppColors.highlight)),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(opportunity.title, style: text.headlineMedium),
          const SizedBox(height: AppSpacing.sm),
          Text(opportunity.description,
              style: text.bodyMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: AppSpacing.md),
          Align(
            alignment: Alignment.centerLeft,
            child: ElevatedButton(
                onPressed: onView, child: const Text('View opportunity')),
          ),
        ],
      ),
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();
  @override
  Widget build(BuildContext context) => const Padding(
      padding: EdgeInsets.all(AppSpacing.xl),
      child: Center(child: CircularProgressIndicator()));
}

class _Message extends StatelessWidget {
  const _Message({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.border),
        ),
        child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
      );
}