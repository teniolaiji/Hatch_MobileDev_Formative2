import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hatch/components/opportunity_card.dart';
import 'package:hatch/providers/opportunity_providers.dart';
import 'package:hatch/providers/user_providers.dart';
import 'package:hatch/router/app_router.dart';
import 'package:hatch/theme/app_colors.dart';
import 'package:hatch/theme/app_spacing.dart';

class FounderRolesScreen extends ConsumerWidget {
  const FounderRolesScreen({super.key});

  void _onPostTap(BuildContext context, WidgetRef ref) {
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final rolesAsync = ref.watch(myOpportunitiesProvider);
    final isVerified =
        ref.watch(currentUserProvider).value?.isVerified ?? false;

    return Scaffold(
      appBar: AppBar(title: const Text('My roles')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _onPostTap(context, ref),
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
                onTap: () =>
                    context.push(Routes.opportunityDetail, extra: roles[i]),
              ),
            );
          },
        ),
      ),
    );
  }
}