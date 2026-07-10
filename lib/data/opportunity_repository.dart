import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/opportunity.dart';

class OpportunityRepository {
  OpportunityRepository(this._db);
  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _opportunities =>
      _db.collection('opportunities');

  Stream<List<Opportunity>> watchOpportunities() {
    return _opportunities
        .snapshots()
        .map(
          (snapshot) {
            final list = snapshot.docs
                .map((doc) => Opportunity.fromMap(doc.id, doc.data()))
                .toList();
            list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
            return list;
          },
        );
  }
}
