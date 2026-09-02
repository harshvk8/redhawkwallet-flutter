import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class AvatarUploadException implements Exception {
  final String message;
  const AvatarUploadException(this.message);

  @override
  String toString() => message;
}

/// Picks a profile photo and uploads it to `avatars/{uid}` in Firebase
/// Storage, then writes the resulting download URL to both the user's
/// Firestore doc (`photoUrl`, read by the rest of the app) and Firebase
/// Auth's own `photoURL` (kept in sync for anything reading it directly
/// off `FirebaseAuth.instance.currentUser`).
class AvatarService {
  final _picker = ImagePicker();

  Future<String?> pickImage(ImageSource source) async {
    try {
      final file = await _picker
          .pickImage(source: source, maxWidth: 1024, imageQuality: 85)
          .timeout(const Duration(seconds: 60));
      return file?.path;
    } on TimeoutException {
      throw const AvatarUploadException('The photo picker took too long to respond. Please try again.');
    }
  }

  Future<String> uploadAvatar(String filePath) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw const AvatarUploadException('You must be signed in to update your photo.');
    }

    try {
      final ref = FirebaseStorage.instance.ref('avatars/${user.uid}');
      await ref
          .putFile(
            File(filePath),
            SettableMetadata(contentType: 'image/jpeg'),
          )
          .timeout(const Duration(seconds: 30));
      final url = await ref.getDownloadURL();

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
        {'photoUrl': url, 'updatedAt': Timestamp.now()},
        SetOptions(merge: true),
      );
      await user.updatePhotoURL(url);
      await user.reload();

      return url;
    } on FirebaseException catch (e) {
      throw AvatarUploadException(e.message ?? 'Could not upload photo.');
    } on TimeoutException {
      throw const AvatarUploadException('Uploading the photo took too long. Please check your connection and try again.');
    }
  }
}
