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

// ── Main body ─────────────────────────────────────────────────────────────────

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
    final topMatch = opportunities.isEmpty ? null : opportunities.first;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        // ── Greeting ─────────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 2),
          child: Text(
            greetingForNow(),
            style: text.bodyMedium
                ?.copyWith(color: AppColors.textSecondary),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.xl),
          child: Text(
            firstName.isEmpty ? 'Welcome.' : '$firstName.',
            style: text.displayMedium?.copyWith(
              color: AppColors.textPrimary,
              height: 1.1,
            ),
          ),
        ),

        // ── Browse by category ────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.sm),
          child: Text(
            'BROWSE BY CATEGORY',
            style: text.labelSmall?.copyWith(
              color: AppColors.textSecondary,
              letterSpacing: 1.2,
            ),
          ),
        ),
        SizedBox(
          height: 84,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            children: OpportunityCategory.values
                .map((cat) => _CategoryTile(category: cat))
                .toList(),
          ),
        ),

        // ── Divider ───────────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.lg,
          ),
          child: Divider(height: 1, color: AppColors.border),
        ),

        // ── Top match ─────────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.sm),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'BEST MATCH',
                style: text.labelSmall?.copyWith(
                  color: AppColors.textSecondary,
                  letterSpacing: 1.2,
                ),
              ),
              GestureDetector(
                onTap: () => context.go(Routes.discover),
                child: Text(
                  'See all →',
                  style: text.labelSmall?.copyWith(
                    color: AppColors.textPrimary,
                  ),
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

        const SizedBox(height: AppSpacing.lg),

        // ── Applications shortcut ─────────────────────────────────────────────
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

// ── Category tile ─────────────────────────────────────────────────────────────

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
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.sm),
      child: GestureDetector(
        onTap: () => context.go(Routes.discover),
        child: Container(
          width: 70,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(_icon, size: 22, color: AppColors.textPrimary),
              const SizedBox(height: AppSpacing.xs),
              Text(
                category.label,
                style: text.labelSmall
                    ?.copyWith(color: AppColors.textPrimary),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Top match card ────────────────────────────────────────────────────────────

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
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.border),
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
                      color: AppColors.textSecondary,
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
                    color: AppColors.sand,
                    borderRadius:
                        BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Text(
                    opportunity.location == LocationType.remote
                        ? 'Remote'
                        : 'On-site',
                    style: text.labelSmall?.copyWith(
                      color: AppColors.taupe,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.xs),
            Text(opportunity.title, style: text.headlineMedium),
            const SizedBox(height: AppSpacing.sm),
            Text(
              opportunity.description,
              style: text.bodyMedium
                  ?.copyWith(color: AppColors.textSecondary),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            // Skills as icon + label
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
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Skill icon + label ────────────────────────────────────────────────────────

class _SkillIcon extends StatelessWidget {
  const _SkillIcon({required this.skill});
  final String skill;

  IconData _icon() {
    final s = skill.toLowerCase();
    if (s.contains('flutter') || s.contains('dart') || s.contains('mobile')) {
      return Icons.phone_android_rounded;
    }
    if (s.contains('react') || s.contains('vue') || s.contains('angular') ||
        s.contains('web')) {
      return Icons.web_rounded;
    }
    if (s.contains('python') || s.contains('java') || s.contains('backend') ||
        s.contains('node')) {
      return Icons.terminal_rounded;
    }
    if (s.contains('figma') || s.contains('ui') || s.contains('ux')) {
      return Icons.brush_rounded;
    }
    if (s.contains('market') || s.contains('social') ||
        s.contains('campaign') || s.contains('canva')) {
      return Icons.campaign_rounded;
    }
    if (s.contains('data') || s.contains('analytic') || s.contains('sql')) {
      return Icons.bar_chart_rounded;
    }
    if (s.contains('copy') || s.contains('writ') || s.contains('content')) {
      return Icons.edit_rounded;
    }
    if (s.contains('video') || s.contains('film')) {
      return Icons.videocam_rounded;
    }
    if (s.contains('research')) return Icons.science_rounded;
    return Icons.star_outline_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon(), size: 18, color: AppColors.textSecondary),
          const SizedBox(height: 2),
          Text(
            skill,
            style: text.labelSmall
                ?.copyWith(color: AppColors.textSecondary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ── Error body ────────────────────────────────────────────────────────────────

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
