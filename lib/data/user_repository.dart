import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_user.dart';

class UserRepository {
  UserRepository(this._db);
  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection('users');

  Future<void> createUser(AppUser user) {
    return _users.doc(user.uid).set(user.toMap());
  }

  Future<AppUser?> fetchUser(String uid) async {
    final doc = await _users.doc(uid).get();
    if (!doc.exists) return null;
    return AppUser.fromMap(doc.data()!);
    
  }

  Future<void> updateSkills(String uid, List<String> skills) {
    return _users.doc(uid).update({'skills': skills});
  }

  // Update any subset of a user's profile fields.
  Future<void> updateProfile(String uid, Map<String, dynamic> fields) {
    return _users.doc(uid).update(fields);
  }
}
