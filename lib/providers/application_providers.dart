import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/application_repository.dart';
import '../models/application.dart';
import 'user_providers.dart';

final applicationRepositoryProvider = Provider<ApplicationRepository>((ref) {
  return ApplicationRepository(FirebaseFirestore.instance);
});

final myApplicationsProvider = StreamProvider<List<Application>>((ref) {
  final uid = ref.watch(currentUserProvider).value?.uid;
  if (uid == null) return const Stream.empty();
  return ref.watch(applicationRepositoryProvider).watchMyApplications(uid);
});

final startupApplicationsProvider = StreamProvider<List<Application>>((ref) {
  final user = ref.watch(currentUserProvider).value;
  if (user == null) return Stream.value([]);
  return ref
      .watch(applicationRepositoryProvider)
      .watchForStartup(user.uid);
});