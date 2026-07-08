import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';
import 'user_service.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _userService = UserService();

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<UserCredential> signIn(String email, String password) =>
      _auth.signInWithEmailAndPassword(email: email, password: password);

  Future<UserCredential> register(
      String email, String password, String name,
      {String? role,
      Map<String, dynamic>? vendorData,
      DateTime? termsAcceptedAt}) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await credential.user?.updateDisplayName(name);
    await _userService.createUserDocument(
      credential.user!,
      name,
      role: role ?? UserRole.normalUser,
      vendorData: vendorData,
      termsAcceptedAt: termsAcceptedAt,
    );
    return credential;
  }

  Future<void> sendEmailVerification() =>
      _auth.currentUser!.sendEmailVerification();

  Future<User?> reloadUser() async {
    await _auth.currentUser?.reload();
    return _auth.currentUser;
  }

  Future<void> signOut() => _auth.signOut();
}
