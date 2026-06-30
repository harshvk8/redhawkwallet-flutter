import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';

class UserService {
  final _db = FirebaseFirestore.instance;

  Future<void> createUserDocument(User firebaseUser, String name,
      {String role = UserRole.normalUser,
      Map<String, dynamic>? vendorData}) async {
    final now = DateTime.now();
    final data = UserModel(
      uid: firebaseUser.uid,
      name: name,
      email: firebaseUser.email ?? '',
      role: role,
      isEmailVerified: false,
      isUniversityVerified: false,
      createdAt: now,
      updatedAt: now,
    ).toMap();
    if (vendorData != null) {
      data.addAll(vendorData);
    }
    await _db.collection('users').doc(firebaseUser.uid).set(data);
    await _db.collection('wallets').doc(firebaseUser.uid).set({
      'balance': 0.0,
      'points': 0,
      'updatedAt': Timestamp.fromDate(now),
    });
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
    await _db.collection('users').doc(uid).set({
      'universityEmail': universityEmail,
      'isUniversityVerified': true,
      'role': UserRole.verifiedStudent,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    }, SetOptions(merge: true));
  }
}
