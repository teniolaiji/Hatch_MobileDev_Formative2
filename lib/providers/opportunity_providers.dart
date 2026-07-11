import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/opportunity_repository.dart';
import '../models/opportunity.dart';
import '../providers/user_providers.dart';

final opportunityRepositoryProvider = Provider<OpportunityRepository>((ref) {
  return OpportunityRepository(FirebaseFirestore.instance);
});

final opportunitiesProvider = StreamProvider<List<Opportunity>>((ref) {
  return ref.watch(opportunityRepositoryProvider).watchOpportunities();
});

final myOpportunitiesProvider = StreamProvider<List<Opportunity>>((ref) {
  final user = ref.watch(currentUserProvider).value;
  if (user == null) return Stream.value([]);
  return ref.watch(opportunityRepositoryProvider).watchByOwner(user.uid);
});

// Strips corrupt docs (trailing-space field names → empty title) from every derived provider.
List<Opportunity> _valid(List<Opportunity> list) =>
    list.where((o) => o.title.isNotEmpty).toList();

final topMatchProvider = Provider<Opportunity?>((ref) {
  final opportunities = _valid(ref.watch(opportunitiesProvider).value ?? []);
  return opportunities.isEmpty ? null : opportunities.first;
});

class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';
  void set(String query) => state = query;
}

final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(
  SearchQueryNotifier.new,
);

final filteredOpportunitiesProvider = Provider<List<Opportunity>>((ref) {
  final query = ref.watch(searchQueryProvider).trim().toLowerCase();
  final category = ref.watch(selectedCategoryProvider);
  final all = _valid(ref.watch(opportunitiesProvider).value ?? []);

  var results = category != null
      ? all.where((o) => o.category == category).toList()
      : all;

  if (query.isEmpty) return results;
  return results.where((o) {
    final haystack = [
      o.title,
      o.startupName,
      ...o.requiredSkills,
    ].join(' ').toLowerCase();
    return haystack.contains(query);
  }).toList();
});

class SelectedCategory extends Notifier<OpportunityCategory?> {
  @override
  OpportunityCategory? build() => null;
  void set(OpportunityCategory? value) => state = value;
}

final selectedCategoryProvider =
    NotifierProvider<SelectedCategory, OpportunityCategory?>(
      SelectedCategory.new,
    );

final opportunitiesByCategoryProvider = Provider<List<Opportunity>>((ref) {
  final category = ref.watch(selectedCategoryProvider);
  final all = _valid(ref.watch(opportunitiesProvider).value ?? []);
  if (category == null) return all;
  return all.where((o) => o.category == category).toList();
});
