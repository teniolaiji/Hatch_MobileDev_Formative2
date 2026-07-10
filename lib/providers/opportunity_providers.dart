import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/opportunity_repository.dart';
import '../models/opportunity.dart';

final opportunityRepositoryProvider = Provider<OpportunityRepository>((ref) {
  return OpportunityRepository(FirebaseFirestore.instance);
});

final opportunitiesProvider = StreamProvider<List<Opportunity>>((ref) {
  return ref.watch(opportunityRepositoryProvider).watchOpportunities();
});

final topMatchProvider = Provider<Opportunity?>((ref) {
  final opportunities = ref.watch(opportunitiesProvider).value ?? [];
  return opportunities.isEmpty ? null : opportunities.first;
});

class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';
  void set(String query) => state = query;
}

final searchQueryProvider =
    NotifierProvider<SearchQueryNotifier, String>(SearchQueryNotifier.new);

final filteredOpportunitiesProvider = Provider<List<Opportunity>>((ref) {
  final query = ref.watch(searchQueryProvider).trim().toLowerCase();
  final all = ref.watch(opportunitiesProvider).value ?? [];
  if (query.isEmpty) return all;
  return all.where((o) {
    final haystack =
        [o.title, o.startupName, ...o.requiredSkills].join(' ').toLowerCase();
    return haystack.contains(query);
  }).toList();
});