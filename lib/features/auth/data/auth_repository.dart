import 'package:firebase_auth/firebase_auth.dart';


class AuthRepository {
  AuthRepository(this._auth);
  final FirebaseAuth _auth;

 
  Stream<User?> get authStateChanges => _auth.authStateChanges();


  User? get currentUser => _auth.currentUser;


  Future<void> signInAnonymously() => _auth.signInAnonymously();

  Future<void> signOut() => _auth.signOut();
}