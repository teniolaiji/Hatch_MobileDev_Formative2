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
  bool _showSavedOnly = false;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _toggleSave(String opportunityId) async {
    final user = ref.read(currentUserProvider).value;
    if (user == null) return;
    final current = user.savedOpportunities;
    final updated = current.contains(opportunityId)
        ? current.where((id) => id != opportunityId).toList()
        : [...current, opportunityId];
    await ref
        .read(userRepositoryProvider)
        .updateProfile(user.uid, {'savedOpportunities': updated});
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final rawQuery = ref.watch(searchQueryProvider);
    final query = rawQuery.trim().toLowerCase();
    final category = ref.watch(selectedCategoryProvider);
    final userSkills = ref.watch(currentUserProvider).value?.skills ?? [];
    final savedIds = ref.watch(savedOpportunityIdsProvider);
    final opportunitiesAsync = ref.watch(opportunitiesProvider);

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
    if (_showSavedOnly) {
      results = results.where((o) => savedIds.contains(o.id)).toList();
    }

    final activeFilters = (category != null ? 1 : 0) + (_showSavedOnly ? 1 : 0);

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

            // ── Active filter pills ──────────────────────────────────────────
            if (activeFilters > 0)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.sm),
                child: Row(
                  children: [
                    if (category != null)
                      _FilterPill(
                        label: category.label,
                        onRemove: () => ref
                            .read(selectedCategoryProvider.notifier)
                            .set(null),
                      ),
                    if (category != null && _showSavedOnly)
                      const SizedBox(width: AppSpacing.sm),
                    if (_showSavedOnly)
                      _FilterPill(
                        label: 'Saved',
                        onRemove: () =>
                            setState(() => _showSavedOnly = false),
                      ),
                  ],
                ),
              ),

            Expanded(
              child: opportunitiesAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
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
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _showSavedOnly
                                    ? 'No saved roles yet.\nTap the bookmark icon on any role to save it.'
                                    : (query.isEmpty && category == null
                                        ? 'No opportunities yet. Check back soon.'
                                        : 'No matches found.'),
                                style: text.bodyMedium,
                                textAlign: TextAlign.center,
                              ),
                            ],
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
                        itemBuilder: (context, i) {
                          final opp = results[i];
                          return OpportunityCard(
                            opportunity: opp,
                            score: computeMatchScore(userSkills, opp),
                            isSaved: savedIds.contains(opp.id),
                            onToggleSave: () => _toggleSave(opp.id),
                            onTap: () => context.push(
                              Routes.opportunityDetail,
                              extra: opp,
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
      // Saved filter toggle in FAB
      floatingActionButton: FloatingActionButton.small(
        onPressed: () => setState(() => _showSavedOnly = !_showSavedOnly),
        backgroundColor:
            _showSavedOnly ? AppColors.navy : AppColors.surface,
        foregroundColor:
            _showSavedOnly ? AppColors.cream : AppColors.stone,
        elevation: 2,
        tooltip: _showSavedOnly ? 'Show all' : 'Show saved',
        child: Icon(
            _showSavedOnly ? Icons.bookmark : Icons.bookmark_border),
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({required this.label, required this.onRemove});
  final String label;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: onRemove,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: AppColors.navy,
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label,
                style: text.labelSmall?.copyWith(color: AppColors.cream)),
            const SizedBox(width: 4),
            const Icon(Icons.close, size: 12, color: AppColors.cream),
          ],
        ),
      ),
    );
  }
}
