import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hatch/models/application.dart';

// Reads and writes the 'applications' collection.
class ApplicationRepository {
  ApplicationRepository(this._db);
  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _applications =>
      _db.collection('applications');

  // Create a new application. Firestore assigns the id.
  Future<void> submit(Application application) {
    return _applications.add(application.toMap());
  }

  Future<bool> hasApplied({
    required String applicantId,
    required String opportunityId,
  }) async {
    final snapshot = await _applications
        .where('applicantId', isEqualTo: applicantId)
        .where('opportunityId', isEqualTo: opportunityId)
        .limit(1)
        .get();
    return snapshot.docs.isNotEmpty;
  }

  // Live list of a student's own applications, newest first.
  Stream<List<Application>> watchForApplicant(String applicantId) {
    return _applications
        .where('applicantId', isEqualTo: applicantId)
        .snapshots()
        .map((s) => s.docs
            .map((d) => Application.fromMap(d.id, d.data()))
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt)));
  }
}