import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/startup.dart';

class StartupRepository {
  StartupRepository(this._db);
  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _startups =>
      _db.collection('startups');

  Future<Startup?> fetchStartup(String id) async {
    final doc = await _startups.doc(id).get();
    if (!doc.exists) return null;
    return Startup.fromMap(doc.id, doc.data()!);
  }

  Future<void> createStartup(Startup startup) {
    return _startups.doc(startup.id).set(startup.toMap());
  }

  Stream<List<Startup>> watchStartups() {
    return _startups.snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => Startup.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }
}
