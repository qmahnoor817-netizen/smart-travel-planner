import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser; // <-- add this line
  Stream<User?> get user => _auth.authStateChanges();

  Future<User?> signUp(String email, String pass) async {
    final cred = await _auth.createUserWithEmailAndPassword(email: email, password: pass);
    return cred.user;
  }

  Future<User?> login(String email, String pass) async {
    final cred = await _auth.signInWithEmailAndPassword(email: email, password: pass);
    return cred.user;
  }

  Future<void> logout() => _auth.signOut();
}