import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/startup_repository.dart';
import '../models/startup.dart';

final startupRepositoryProvider = Provider<StartupRepository>((ref) {
  return StartupRepository(FirebaseFirestore.instance);
});

final startupsProvider = StreamProvider<List<Startup>>((ref) {
  return ref.watch(startupRepositoryProvider).watchStartups();
});
