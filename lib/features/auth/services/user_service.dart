import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';

class UserService {
  final _db = FirebaseFirestore.instance;

  Future<void> createUserDocument(User firebaseUser, String name,
      {String role = UserRole.normalUser,
      Map<String, dynamic>? vendorData,
      DateTime? termsAcceptedAt}) async {
    final now = DateTime.now();
    final acceptedAt = termsAcceptedAt ?? now;
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

    // Account status
    data['accountStatus'] = 'active';

    // Vendor-specific fields
    if (role == UserRole.vendor) {
      data['vendorStatus'] = 'pending';
    }

    // Legal consent — written at registration so we have a paper trail
    data['termsAccepted'] = true;
    data['termsAcceptedAt'] = Timestamp.fromDate(acceptedAt);
    data['termsVersion'] = '1.0';
    data['privacyAccepted'] = true;
    data['privacyAcceptedAt'] = Timestamp.fromDate(acceptedAt);
    data['privacyVersion'] = '1.0';

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

  /// Normalizes a phone number to digits-only so formatting differences
  /// ("555-123-4567" vs "5551234567") don't create false mismatches.
  static String normalizePhone(String input) => input.replaceAll(RegExp(r'[^0-9]'), '');

  /// Updates the caller's own name and/or phone number. Rejects a phone
  /// number that's already registered to a different account, since the
  /// Send Money "enter a phone number" lookup depends on numbers being
  /// unique enough to resolve to a single person.
  Future<void> updateProfile(String uid, {String? name, String? phoneNumber}) async {
    if (phoneNumber != null && phoneNumber.isNotEmpty) {
      final existing = await _db
          .collection('users')
          .where('phoneNumber', isEqualTo: phoneNumber)
          .limit(1)
          .get();
      if (existing.docs.isNotEmpty && existing.docs.first.id != uid) {
        throw Exception('That phone number is already registered to another account.');
      }
    }

    final data = <String, dynamic>{'updatedAt': Timestamp.fromDate(DateTime.now())};
    if (name != null) data['name'] = name;
    if (phoneNumber != null) data['phoneNumber'] = phoneNumber;
    await _db.collection('users').doc(uid).set(data, SetOptions(merge: true));
  }
}
