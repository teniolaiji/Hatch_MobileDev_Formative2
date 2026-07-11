import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hatch/models/application.dart';
import 'package:hatch/providers/application_providers.dart';
import 'package:hatch/providers/opportunity_providers.dart';
import 'package:hatch/providers/user_providers.dart';
import 'package:hatch/router/app_router.dart';
import 'package:hatch/theme/app_colors.dart';
import 'package:hatch/theme/app_spacing.dart';
import 'package:hatch/utils/greeting.dart';

class FounderHomeScreen extends ConsumerWidget {
  const FounderHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final user = ref.watch(currentUserProvider).value;
    final roles = ref.watch(myOpportunitiesProvider).value ?? [];
    final applications = ref.watch(startupApplicationsProvider).value ?? [];

    final firstName = (user?.name ?? '').split(' ').first;
    final isVerified = user?.isVerified ?? false;

    final pending = applications
        .where((a) => a.status == ApplicationStatus.submitted)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final totalApplicants = applications.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // ── Greeting ────────────────────────────────────────────────────
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

            // ── Verification banner ──────────────────────────────────────────
            if (!isVerified)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.ochre.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(
                        color: AppColors.ochre.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.verified_outlined,
                          color: AppColors.ochre, size: 20),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          'Verification pending. You\'ll be able to post roles once approved.',
                          style: text.bodySmall
                              ?.copyWith(color: AppColors.ochre),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // ── Stats row ────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
              child: Row(
                children: [
                  _StatTile(
                    label: 'Roles',
                    value: '${roles.length}',
                    onTap: () => context.go(Routes.founderRoles),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _StatTile(
                    label: 'Applicants',
                    value: '$totalApplicants',
                    onTap: () => context.go(Routes.founderApplicants),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _StatTile(
                    label: 'To review',
                    value: '${pending.length}',
                    highlight: pending.isNotEmpty,
                    onTap: () => context.go(Routes.founderApplicants),
                  ),
                ],
              ),
            ),

            // ── Needs attention ──────────────────────────────────────────────
            if (pending.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.sm),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'NEEDS REVIEW',
                      style: text.labelSmall?.copyWith(
                        color: AppColors.navy,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.go(Routes.founderApplicants),
                      child: Text(
                        'See all →',
                        style:
                            text.labelSmall?.copyWith(color: AppColors.taupe),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: pending.take(3).toList().asMap().entries.map((e) {
                      final i = e.key;
                      final app = e.value;
                      final isLast = i == (pending.length > 3 ? 2 : pending.length - 1);
                      return Column(
                        children: [
                          InkWell(
                            onTap: () => context.push(
                                Routes.applicantDetail, extra: app),
                            borderRadius: i == 0
                                ? const BorderRadius.vertical(
                                    top: Radius.circular(AppRadius.lg))
                                : (isLast
                                    ? const BorderRadius.vertical(
                                        bottom: Radius.circular(AppRadius.lg))
                                    : BorderRadius.zero),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                                vertical: AppSpacing.sm,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(app.applicantName,
                                            style: text.titleSmall),
                                        const SizedBox(height: 2),
                                        Text(
                                          app.opportunityTitle,
                                          style: text.bodySmall?.copyWith(
                                              color: AppColors.stone),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  Icon(Icons.chevron_right,
                                      size: 18, color: AppColors.stone),
                                ],
                              ),
                            ),
                          ),
                          if (!isLast) Divider(height: 1, color: AppColors.border),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],

            // ── Empty state when no activity yet ────────────────────────────
            if (roles.isEmpty && applications.isEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.lg),
                child: Text(
                  isVerified
                      ? 'Post your first role to start receiving applications.'
                      : 'Once verified, post your first role to start receiving applications.',
                  style: text.bodyMedium
                      ?.copyWith(color: AppColors.textSecondary),
                ),
              ),

            // ── Quick action ─────────────────────────────────────────────────
            if (isVerified)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.xxl),
                child: OutlinedButton.icon(
                  onPressed: () => context.push(Routes.postOpportunity),
                  icon: const Icon(Icons.add),
                  label: const Text('Post a new role'),
                ),
              )
            else
              const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }
}

// ── Stat tile ────────────────────────────────────────────────────────────────

class _StatTile extends StatelessWidget {
  const _StatTile({
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
        ? AppColors.navy.withValues(alpha: 0.06)
        : AppColors.surface;
    final border =
        highlight ? AppColors.navy.withValues(alpha: 0.2) : AppColors.border;

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
                  color: AppColors.navy,
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