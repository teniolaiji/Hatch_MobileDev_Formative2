import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/application.dart';
import '../models/meeting.dart';

class ApplicationRepository {
  ApplicationRepository(this._db);
  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _applications =>
      _db.collection('applications');

  Future<void> submit(Application application) async {
    final doc = _applications.doc();
    await doc.set({...application.toMap(), 'id': doc.id});
  }

  Future<bool> hasApplied({
    required String applicantId,
    required String opportunityId,
  }) async {
    final snap = await _applications
        .where('applicantId', isEqualTo: applicantId)
        .where('opportunityId', isEqualTo: opportunityId)
        .limit(1)
        .get();
    return snap.docs.isNotEmpty;
  }

  Stream<List<Application>> watchMyApplications(String applicantId) {
    return _applications
        .where('applicantId', isEqualTo: applicantId)
        .snapshots()
        .map((snap) {
          final list = snap.docs
              .map((doc) => Application.fromMap(doc.id, doc.data()))
              .toList();
          list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return list;
        });
  }
  // Live list of applications submitted to a given startup
Stream<List<Application>> watchForStartup(String startupId) {
  return _applications
      .where('startupId', isEqualTo: startupId)
      .snapshots()
      .map((s) => s.docs
          .map((d) => Application.fromMap(d.id, d.data()))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt)));
}

  /// Update one application's status (accept or reject).
  Future<void> updateStatus(String applicationId, ApplicationStatus status) {
    return _applications.doc(applicationId).update({'status': status.name});
  }

  /// Append a meeting to an application using arrayUnion (concurrent-safe).
  Future<void> addMeeting(String applicationId, Meeting meeting) {
    return _applications.doc(applicationId).update({
      'meetings': FieldValue.arrayUnion([meeting.toMap()]),
    });
  }
}

