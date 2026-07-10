import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hatch/data/application_repository.dart';
import 'package:hatch/models/application.dart';
import 'package:hatch/providers/user_providers.dart';

final applicationRepositoryProvider = Provider<ApplicationRepository>((ref) {
  return ApplicationRepository(FirebaseFirestore.instance);
});

final myApplicationsProvider = StreamProvider<List<Application>>((ref) {
  final user = ref.watch(currentUserProvider).value;
  if (user == null) return Stream.value([]);
  return ref.watch(applicationRepositoryProvider).watchForApplicant(user.uid);
});
