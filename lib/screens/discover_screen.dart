import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hatch/components/opportunity_card.dart';
import 'package:hatch/models/opportunity.dart';
import 'package:hatch/providers/opportunity_providers.dart';
import 'package:hatch/providers/user_providers.dart';
import 'package:hatch/utils/match_score.dart';
import 'package:hatch/router/app_router.dart';
import 'package:hatch/theme/app_colors.dart';
import 'package:hatch/theme/app_spacing.dart';
import 'package:go_router/go_router.dart';

class DiscoverScreen extends ConsumerStatefulWidget {
  const DiscoverScreen({super.key});

  @override
  ConsumerState<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends ConsumerState<DiscoverScreen> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final rawQuery = ref.watch(searchQueryProvider);
    final query = rawQuery.trim().toLowerCase();
    final category = ref.watch(selectedCategoryProvider);
    final userSkills =
        ref.watch(currentUserProvider).value?.skills ?? [];
    final opportunitiesAsync = ref.watch(opportunitiesProvider);

    // Inline filtering so THIS widget directly subscribes to category/query
    // changes and rebuilds itself — avoids StatefulShellRoute rebuild gaps.
    var results = (opportunitiesAsync.value ?? [])
        .where((o) => o.title.isNotEmpty)
        .toList();
    if (category != null) {
      results = results.where((o) => o.category == category).toList();
    }
    if (query.isNotEmpty) {
      results = results.where((o) {
        final haystack = [o.title, o.startupName, ...o.requiredSkills]
            .join(' ')
            .toLowerCase();
        return haystack.contains(query);
      }).toList();
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Discover')),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.sm),
              child: TextField(
                controller: _search,
                onChanged: (value) =>
                    ref.read(searchQueryProvider.notifier).set(value),
                decoration: InputDecoration(
                  hintText: 'Search roles, startups, skills',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: rawQuery.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            _search.clear();
                            ref.read(searchQueryProvider.notifier).set('');
                          },
                        ),
                ),
              ),
            ),
            // Active category filter pill
            if (category != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.sm),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => ref
                          .read(selectedCategoryProvider.notifier)
                          .set(null),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.navy,
                          borderRadius:
                              BorderRadius.circular(AppRadius.xl),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              category.label,
                              style: text.labelSmall
                                  ?.copyWith(color: AppColors.cream),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.close,
                                size: 12, color: AppColors.cream),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: opportunitiesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Text(
                    'Could not load opportunities.',
                    style: text.bodyMedium,
                  ),
                ),
                data: (_) => results.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          child: Text(
                            query.isEmpty && category == null
                                ? 'No opportunities yet. Check back soon.'
                                : 'No matches found.',
                            style: text.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.lg,
                          0,
                          AppSpacing.lg,
                          AppSpacing.lg,
                        ),
                        itemCount: results.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: AppSpacing.md),
                        itemBuilder: (context, i) => OpportunityCard(
                          opportunity: results[i],
                          score: computeMatchScore(userSkills, results[i]),
                          onTap: () => context.push(
                            Routes.opportunityDetail,
                            extra: results[i],
                          ),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
