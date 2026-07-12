import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/user_repository.dart';
import '../models/app_user.dart';
import 'auth_providers.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(FirebaseFirestore.instance);
});

final currentUserProvider = StreamProvider<AppUser?>((ref) {
  final authUser = ref.watch(authStateChangesProvider).value;
  if (authUser == null) return Stream.value(null);
  return ref.watch(userRepositoryProvider).watchUser(authUser.uid);
});

final userByIdProvider = FutureProvider.family<AppUser?, String>((
  ref,
  uid,
) async {
  return ref.watch(userRepositoryProvider).fetchUser(uid);
});

/// The current student's saved opportunity IDs as a Set for O(1) lookup.
final savedOpportunityIdsProvider = Provider<Set<String>>((ref) {
  final saved =
      ref.watch(currentUserProvider).value?.savedOpportunities ?? [];
  return saved.toSet();
});
