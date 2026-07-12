import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hatch/components/opportunity_card.dart';
import 'package:hatch/models/opportunity.dart';
import 'package:hatch/providers/application_providers.dart';
import 'package:hatch/providers/opportunity_providers.dart';
import 'package:hatch/providers/user_providers.dart';
import 'package:hatch/router/app_router.dart';
import 'package:hatch/theme/app_colors.dart';
import 'package:hatch/theme/app_spacing.dart';

class FounderRolesScreen extends ConsumerStatefulWidget {
  const FounderRolesScreen({super.key});

  @override
  ConsumerState<FounderRolesScreen> createState() => _FounderRolesScreenState();
}

class _FounderRolesScreenState extends ConsumerState<FounderRolesScreen> {
  void _onPostTap(BuildContext context) {
    final isVerified =
        ref.read(currentUserProvider).value?.isVerified ?? false;

    if (isVerified) {
      context.push(Routes.postOpportunity);
      return;
    }

    // Unverified — explain instead of navigating.
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Icon(Icons.verified_outlined, size: 40, color: AppColors.navy),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Verification required',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Your startup needs to be verified before you can post roles. '
              'Reach out to the Hatch team to get verified — it usually takes 1–2 days.',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(Opportunity role) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete this role?'),
        content: Text(
          '"${role.title}" will be permanently removed. '
          'Existing applications will still be visible to you.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await ref.read(opportunityRepositoryProvider).delete(role.id);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not delete: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final rolesAsync = ref.watch(myOpportunitiesProvider);
    final isVerified =
        ref.watch(currentUserProvider).value?.isVerified ?? false;

    // Build opportunityId → applicant count map from the already-streamed list.
    final applicationsSnap = ref.watch(startupApplicationsProvider);
    final countByRole = <String, int>{};
    for (final app in applicationsSnap.value ?? []) {
      countByRole[app.opportunityId] =
          (countByRole[app.opportunityId] ?? 0) + 1;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('My roles')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _onPostTap(context),
        backgroundColor: isVerified ? null : AppColors.stone,
        icon: Icon(isVerified ? Icons.add : Icons.lock_outline),
        label: const Text('Post a role'),
      ),
      body: SafeArea(
        child: rolesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
              child: Text('Could not load your roles.',
                  style: text.bodyMedium)),
          data: (roles) {
            if (roles.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isVerified
                            ? 'You have not posted any roles yet.\nTap "Post a role" to create one.'
                            : 'Your account is pending verification.\nOnce verified, you can post roles.',
                        style: text.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: roles.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, i) => OpportunityCard(
                opportunity: roles[i],
                showExpired: true,
                applicantCount: countByRole[roles[i].id] ?? 0,
                onTap: () =>
                    context.push(Routes.opportunityDetail, extra: roles[i]),
                onEdit: () => context.push(
                    Routes.editOpportunity,
                    extra: roles[i]),
                onDelete: () => _confirmDelete(roles[i]),
              ),
            );
          },
        ),
      ),
    );
  }
}