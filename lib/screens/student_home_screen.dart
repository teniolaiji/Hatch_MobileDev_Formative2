import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/opportunity.dart';
import '../providers/user_providers.dart';
import '../providers/opportunity_providers.dart';
import '../router/app_router.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../utils/greeting.dart';

class StudentHomeScreen extends ConsumerWidget {
  const StudentHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).value;
    final opportunitiesAsync = ref.watch(opportunitiesProvider);
    final firstName = (user?.name ?? '').split(' ').first;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: opportunitiesAsync.when(
          loading: () =>
              const Center(child: CircularProgressIndicator()),
          error: (e, _) => _ErrorBody(error: e),
          data: (opportunities) => _HomeBody(
            firstName: firstName,
            opportunities: opportunities,
          ),
        ),
      ),
    );
  }
}


class _HomeBody extends StatelessWidget {
  const _HomeBody({
    required this.firstName,
    required this.opportunities,
  });

  final String firstName;
  final List<Opportunity> opportunities;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    // Filter out corrupt docs (empty title = trailing-space field names in Firestore)
    final validOpportunities =
        opportunities.where((o) => o.title.isNotEmpty).toList();
    final topMatch =
        validOpportunities.isEmpty ? null : validOpportunities.first;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        // Greeting
        Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 2),
          child: Text(
            greetingForNow(),
            style: text.bodyMedium?.copyWith(color: AppColors.stone),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.xl),
          child: Text(
            firstName.isEmpty ? 'Welcome.' : '$firstName.',
            style: text.displayLarge?.copyWith(
              color: AppColors.navy,
              height: 1.0,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.sm),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'BEST MATCH',
                style: text.labelSmall?.copyWith(
                  color: AppColors.navy,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w700,
                ),
              ),
              GestureDetector(
                onTap: () => context.go(Routes.discover),
                child: Text(
                  'See all →',
                  style: text.labelSmall?.copyWith(color: AppColors.taupe),
                ),
              ),
            ],
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: topMatch == null
              ? Text(
                  'No opportunities yet — check back soon.',
                  style: text.bodyMedium
                      ?.copyWith(color: AppColors.textSecondary),
                )
              : _TopMatchCard(opportunity: topMatch),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.lg,
          ),
          child: Divider(height: 1, color: AppColors.border),
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.md),
          child: Text(
            'CHOOSE CATEGORY',
            style: text.labelSmall?.copyWith(
              color: AppColors.navy,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: OpportunityCategory.values
                .map((cat) => _CategoryTile(category: cat))
                .toList(),
          ),
        ),

        const SizedBox(height: AppSpacing.lg),

        // Applications shortcut 
        Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.xxl),
          child: OutlinedButton(
            onPressed: () => context.go(Routes.applications),
            child: const Text('My applications'),
          ),
        ),
      ],
    );
  }
}

//  Category tile 
class _CategoryTile extends StatelessWidget {
  const _CategoryTile({required this.category});
  final OpportunityCategory category;

  IconData get _icon => switch (category) {
        OpportunityCategory.engineering => Icons.code_rounded,
        OpportunityCategory.design => Icons.brush_rounded,
        OpportunityCategory.marketing => Icons.campaign_rounded,
        OpportunityCategory.research => Icons.science_rounded,
        OpportunityCategory.other => Icons.bolt_rounded,
      };

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: () => context.go(Routes.discover),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.navy,
            ),
            child: Icon(_icon, size: 22, color: AppColors.cream),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            category.label,
            style: text.labelSmall
                ?.copyWith(color: AppColors.textPrimary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// Top match card 

class _TopMatchCard extends StatelessWidget {
  const _TopMatchCard({required this.opportunity});
  final Opportunity opportunity;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: () =>
          context.push(Routes.opportunityDetail, extra: opportunity),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.navy,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Startup name + location badge
            Row(
              children: [
                Expanded(
                  child: Text(
                    opportunity.startupName.toUpperCase(),
                    style: text.labelSmall?.copyWith(
                      color: AppColors.ochre,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Text(
                    opportunity.location == LocationType.remote
                        ? 'Remote'
                        : 'On-site',
                    style: text.labelSmall?.copyWith(color: AppColors.stone),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              opportunity.title,
              style: text.headlineMedium?.copyWith(color: AppColors.cream),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              opportunity.description,
              style: text.bodyMedium?.copyWith(color: AppColors.stone),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (opportunity.requiredSkills.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: opportunity.requiredSkills
                      .take(5)
                      .map((s) => _SkillIcon(skill: s))
                      .toList(),
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'View role →',
                style: text.labelMedium?.copyWith(
                  color: AppColors.ochre,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─Skill pill (on dark navy card) 

class _SkillIcon extends StatelessWidget {
  const _SkillIcon({required this.skill});
  final String skill;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.sm),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        child: Text(
          skill,
          style: text.labelSmall?.copyWith(color: AppColors.stone),
        ),
      ),
    );
  }
}

//  Error body 

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.error});
  final Object error;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Could not load opportunities.',
                style: text.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            Text(
              error.toString(),
              style: text.bodySmall
                  ?.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
