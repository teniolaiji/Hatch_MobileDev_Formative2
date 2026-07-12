import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/opportunity.dart';

class OpportunityRepository {
  OpportunityRepository(this._db);
  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _opportunities =>
      _db.collection('opportunities');

  Stream<List<Opportunity>> watchOpportunities() {
    return _opportunities.snapshots().map((snapshot) {
      final list = snapshot.docs
          .map((doc) => Opportunity.fromMap(doc.id, doc.data()))
          .toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  Stream<List<Opportunity>> watchByOwner(String startupId) {
    return _opportunities
        .where('startupId', isEqualTo: startupId)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs
          .map((doc) => Opportunity.fromMap(doc.id, doc.data()))
          .toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  Future<void> create(Opportunity opportunity) async {
    final doc = _opportunities.doc();
    await doc.set(opportunity.toMap());
  }

  Future<void> update(Opportunity opportunity) {
    return _opportunities.doc(opportunity.id).update(opportunity.toMap());
  }

  Future<void> delete(String id) {
    return _opportunities.doc(id).delete();
  }
}
