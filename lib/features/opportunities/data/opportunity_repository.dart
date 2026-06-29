import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/opportunity.dart';

class OpportunityRepository {
  OpportunityRepository(this._db);
  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _opportunities =>
      _db.collection('opportunities');

  Stream<List<Opportunity>> watchOpportunities() {
    return _opportunities
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Opportunity.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }
}
