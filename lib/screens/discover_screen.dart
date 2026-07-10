import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hatch/components/opportunity_card.dart';
import 'package:hatch/providers/opportunity_providers.dart';
import 'package:hatch/theme/app_spacing.dart';

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
    final query = ref.watch(searchQueryProvider);
    final opportunitiesAsync = ref.watch(opportunitiesProvider);
    final results = ref.watch(filteredOpportunitiesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Discover')),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: TextField(
                controller: _search,
                onChanged: (value) =>
                    ref.read(searchQueryProvider.notifier).set(value),
                decoration: InputDecoration(
                  hintText: 'Search roles, startups, skills',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: query.isEmpty
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
            Expanded(
              child: opportunitiesAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Text('Could not load opportunities.',
                      style: text.bodyMedium),
                ),
                data: (_) => results.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          child: Text(
                            query.isEmpty
                                ? 'No opportunities yet. Check back soon.'
                                : 'No matches for "$query".',
                            style: text.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(
                            AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
                        itemCount: results.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: AppSpacing.md),
                        itemBuilder: (context, i) =>
                            OpportunityCard(opportunity: results[i]),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}