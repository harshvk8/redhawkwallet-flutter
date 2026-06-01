import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';

class UserService {
  final _db = FirebaseFirestore.instance;

  Future<void> createUserDocument(User firebaseUser, String name) async {
    final now = DateTime.now();
    await _db.collection('users').doc(firebaseUser.uid).set(
          UserModel(
            uid: firebaseUser.uid,
            name: name,
            email: firebaseUser.email ?? '',
            role: UserRole.normalUser,
            isEmailVerified: false,
            isUniversityVerified: false,
            createdAt: now,
            updatedAt: now,
          ).toMap(),
        );
  }

  Future<UserModel?> getUserDocument(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  Future<void> updateEmailVerified(String uid) async {
    await _db.collection('users').doc(uid).update({
      'isEmailVerified': true,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  Future<void> updateUniversityVerification(
      String uid, String universityEmail) async {
    await _db.collection('users').doc(uid).update({
      'universityEmail': universityEmail,
      'isUniversityVerified': true,
      'role': UserRole.verifiedStudent,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }
}
