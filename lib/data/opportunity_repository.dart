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
            final list = snapshot.docs.map((doc) {
              final data = doc.data();
              print('=== DOC ${doc.id} ===');
              data.forEach((k, v) => print('  $k: $v (${v.runtimeType})'));
              return Opportunity.fromMap(doc.id, data);
            }).toList();
            list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
            return list;
          },
        );
  }
}
