import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/opportunity_repository.dart';
import '../domain/opportunity.dart';

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