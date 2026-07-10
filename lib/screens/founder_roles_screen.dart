import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hatch/components/opportunity_card.dart';
import 'package:hatch/providers/opportunity_providers.dart';
import 'package:hatch/router/app_router.dart';
import 'package:hatch/theme/app_spacing.dart';

class FounderRolesScreen extends ConsumerWidget {
  const FounderRolesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final rolesAsync = ref.watch(myOpportunitiesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My roles')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(Routes.postOpportunity),
        icon: const Icon(Icons.add),
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
                  child: Text(
                    'You have not posted any roles yet.\nTap "Post a role" to create one.',
                    style: text.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: roles.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, i) => OpportunityCard(
                opportunity: roles[i],
                onTap: () => context.push(Routes.opportunityDetail,
                    extra: roles[i]),
              ),
            );
          },
        ),
      ),
    );
  }
}