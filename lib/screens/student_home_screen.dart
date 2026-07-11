import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../components/verified_badge.dart';
import '../models/app_user.dart';
import '../models/application.dart';
import '../models/opportunity.dart';
import '../providers/application_providers.dart';
import '../providers/user_providers.dart';
import '../providers/opportunity_providers.dart';
import '../router/app_router.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../utils/greeting.dart';
import '../utils/match_score.dart';

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


class _HomeBody extends ConsumerWidget {
  const _HomeBody({
    required this.firstName,
    required this.opportunities,
  });

  final String firstName;
  final List<Opportunity> opportunities;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final user = ref.watch(currentUserProvider).value;
    final userSkills = user?.skills ?? [];
    final allApplications = ref.watch(myApplicationsProvider).value ?? [];
    final savedIds = ref.watch(savedOpportunityIdsProvider);

    final submitted = allApplications
        .where((a) => a.status == ApplicationStatus.submitted)
        .length;
    final reviewing = allApplications
        .where((a) => a.status == ApplicationStatus.reviewing)
        .length;
    final accepted = allApplications
        .where((a) => a.status == ApplicationStatus.accepted)
        .length;

    // Filter out corrupt docs and expired opportunities
    final validOpportunities = opportunities
        .where((o) => o.title.isNotEmpty && !o.isExpired)
        .toList();

    // Pick best match: highest score when skills are set, otherwise newest
    final topMatch = validOpportunities.isEmpty
        ? null
        : (userSkills.isEmpty
            ? validOpportunities.first
            : validOpportunities.reduce((best, opp) {
                final b = computeMatchScore(userSkills, best) ?? 0;
                final o = computeMatchScore(userSkills, opp) ?? 0;
                return o > b ? opp : best;
              }));

    final topScore =
        topMatch != null ? computeMatchScore(userSkills, topMatch) : null;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        // ── Greeting ─────────────────────────────────────────────────────
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
              AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
          child: Text(
            firstName.isEmpty ? 'Welcome.' : '$firstName.',
            style: text.displayLarge?.copyWith(
              color: AppColors.navy,
              height: 1.0,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),

        // ── Profile completeness nudge ───────────────────────────────────
        if (user != null) _ProfileNudge(user: user),

        // ── Best match ───────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.sm),
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
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.xl),
          child: topMatch == null
              ? Text(
                  'No opportunities yet — check back soon.',
                  style: text.bodyMedium
                      ?.copyWith(color: AppColors.textSecondary),
                )
              : _TopMatchCard(opportunity: topMatch, score: topScore),
        ),

        // ── Application stats ────────────────────────────────────────────
        if (allApplications.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.sm),
            child: Text(
              'YOUR APPLICATIONS',
              style: text.labelSmall?.copyWith(
                color: AppColors.navy,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.xl),
            child: Row(
              children: [
                _AppStatTile(
                  label: 'Submitted',
                  value: '$submitted',
                  onTap: () => context.go(Routes.applications),
                ),
                const SizedBox(width: AppSpacing.sm),
                _AppStatTile(
                  label: 'In review',
                  value: '$reviewing',
                  onTap: () => context.go(Routes.applications),
                ),
                const SizedBox(width: AppSpacing.sm),
                _AppStatTile(
                  label: 'Accepted',
                  value: '$accepted',
                  highlight: accepted > 0,
                  onTap: () => context.go(Routes.applications),
                ),
              ],
            ),
          ),
        ],

        // ── Saved roles shortcut ─────────────────────────────────────────
        if (savedIds.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.xl),
            child: GestureDetector(
              onTap: () {
                ref.read(showSavedOnlyProvider.notifier).set(true);
                context.go(Routes.discover);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.navy,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.bookmark,
                        size: 18, color: AppColors.ochre),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        '${savedIds.length} saved ${savedIds.length == 1 ? 'role' : 'roles'}',
                        style: text.bodyMedium
                            ?.copyWith(color: AppColors.cream),
                      ),
                    ),
                    const Icon(Icons.chevron_right,
                        size: 18, color: AppColors.stone),
                  ],
                ),
              ),
            ),
          ),

        // ── Closing soon ─────────────────────────────────────────────────
        const _DeadlineTracker(),

        // ── Browse by category ───────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.sm),
          child: Text(
            'BROWSE BY CATEGORY',
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
                .map((cat) => _CategoryTile(
                      category: cat,
                      onTap: () {
                        ref
                            .read(selectedCategoryProvider.notifier)
                            .set(cat);
                        context.go(Routes.discover);
                      },
                    ))
                .toList(),
          ),
        ),

        const SizedBox(height: AppSpacing.xxl),
      ],
    );
  }
}

//  Category tile 
class _CategoryTile extends StatelessWidget {
  const _CategoryTile({required this.category, required this.onTap});
  final OpportunityCategory category;
  final VoidCallback onTap;

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
      onTap: onTap,
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
  const _TopMatchCard({required this.opportunity, this.score});
  final Opportunity opportunity;
  final int? score;

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
            // Startup name + score badge + location badge
            Row(
              children: [
                Expanded(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          opportunity.startupName.toUpperCase(),
                          style: text.labelSmall?.copyWith(
                            color: AppColors.ochre,
                            letterSpacing: 0.8,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      VerifiedBadge(
                          show: opportunity.startupVerified, onDark: true),
                    ],
                  ),
                ),
                if (score != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.ochre.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                    ),
                    child: Text(
                      '$score% match',
                      style: text.labelSmall
                          ?.copyWith(color: AppColors.ochre),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                ],
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

// ── Deadline countdown ────────────────────────────────────────────────────────

class _DeadlineTracker extends ConsumerWidget {
  const _DeadlineTracker();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final all = ref.watch(opportunitiesProvider).value ?? [];
    final appliedIds = ref
            .watch(myApplicationsProvider)
            .value
            ?.map((a) => a.opportunityId)
            .toSet() ??
        {};

    final now = DateTime.now();
    final cutoff = now.add(const Duration(days: 14));

    final closing = all
        .where((o) =>
            o.title.isNotEmpty &&
            o.deadline != null &&
            !appliedIds.contains(o.id) &&
            o.deadline!.isAfter(now) &&
            o.deadline!.isBefore(cutoff))
        .toList()
      ..sort((a, b) => a.deadline!.compareTo(b.deadline!));

    if (closing.isEmpty) return const SizedBox.shrink();

    final display = closing.take(3).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CLOSING SOON',
            style: text.labelSmall?.copyWith(
              color: AppColors.navy,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: display.asMap().entries.map((entry) {
                final i = entry.key;
                final opp = entry.value;
                final days = opp.deadline!.difference(now).inDays;
                final label = days == 0
                    ? 'Closes today'
                    : days == 1
                        ? '1 day left'
                        : '$days days left';
                final badgeColor = days <= 2
                    ? AppColors.danger
                    : days <= 6
                        ? AppColors.ochre
                        : AppColors.taupe;

                return Column(
                  children: [
                    GestureDetector(
                      onTap: () => context.push(
                          Routes.opportunityDetail,
                          extra: opp),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    opp.title,
                                    style: text.titleSmall?.copyWith(
                                        color: AppColors.textPrimary),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    opp.startupName,
                                    style: text.bodySmall
                                        ?.copyWith(color: AppColors.stone),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                                vertical: AppSpacing.xs,
                              ),
                              decoration: BoxDecoration(
                                color: badgeColor.withValues(alpha: 0.12),
                                borderRadius:
                                    BorderRadius.circular(AppRadius.sm),
                              ),
                              child: Text(
                                label,
                                style: text.labelSmall
                                    ?.copyWith(color: badgeColor),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (i < display.length - 1)
                      Divider(height: 1, color: AppColors.border),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Application stat tile ────────────────────────────────────────────────────

class _AppStatTile extends StatelessWidget {
  const _AppStatTile({
    required this.label,
    required this.value,
    this.highlight = false,
    this.onTap,
  });

  final String label;
  final String value;
  final bool highlight;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final bg = highlight
        ? AppColors.green.withValues(alpha: 0.08)
        : AppColors.surface;
    final border =
        highlight ? AppColors.green.withValues(alpha: 0.3) : AppColors.border;
    final valueColor = highlight ? AppColors.green : AppColors.navy;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.md, horizontal: AppSpacing.sm),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: border),
          ),
          child: Column(
            children: [
              Text(
                value,
                style: text.headlineMedium?.copyWith(
                  color: valueColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: text.labelSmall?.copyWith(color: AppColors.stone),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Profile completeness nudge ────────────────────────────────────────────────

class _ProfileNudge extends StatelessWidget {
  const _ProfileNudge({required this.user});
  final AppUser user;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    final sections = [
      (label: 'Bio', done: user.bio.isNotEmpty, route: Routes.editAbout),
      (label: 'Skills', done: user.skills.isNotEmpty, route: Routes.editSkills),
      (label: 'Interests', done: user.interests.isNotEmpty, route: Routes.editInterests),
      (label: 'Experience', done: user.experience.isNotEmpty, route: Routes.editExperience),
      (label: 'Education', done: user.education.isNotEmpty, route: Routes.editEducation),
    ];

    final completed = sections.where((s) => s.done).length;
    final missing = sections.where((s) => !s.done).toList();

    // Disappears once profile is complete
    if (missing.isEmpty) return const SizedBox.shrink();

    final progress = completed / sections.length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.xl),
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
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Complete your profile',
                  style: text.titleSmall
                      ?.copyWith(color: AppColors.textPrimary),
                ),
                Text(
                  '$completed / ${sections.length}',
                  style: text.labelSmall?.copyWith(color: AppColors.taupe),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),

            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 4,
                backgroundColor: AppColors.border,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppColors.navy),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Tappable missing-section chips (max 3 shown)
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: missing.take(3).map((s) {
                return GestureDetector(
                  onTap: () => context.push(s.route),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.navy.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                      border: Border.all(
                          color: AppColors.navy.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.add_rounded,
                            size: 12, color: AppColors.navy),
                        const SizedBox(width: 3),
                        Text(
                          'Add ${s.label}',
                          style: text.labelSmall
                              ?.copyWith(color: AppColors.navy),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

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
