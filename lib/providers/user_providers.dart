import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/user_repository.dart';
import '../models/app_user.dart';
import 'auth_providers.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(FirebaseFirestore.instance);
});

final currentUserProvider = FutureProvider<AppUser?>((ref) async {
  final authUser = ref.watch(authStateChangesProvider).value;
  if (authUser == null) return null;
  return ref.watch(userRepositoryProvider).fetchUser(authUser.uid);
});

final userByIdProvider = FutureProvider.family<AppUser?, String>((
  ref,
  uid,
) async {
  return ref.watch(userRepositoryProvider).fetchUser(uid);
});
