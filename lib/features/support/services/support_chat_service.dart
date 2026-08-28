import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SupportChatException implements Exception {
  final String message;
  const SupportChatException(this.message);

  @override
  String toString() => message;
}

/// Wraps the support-chat Cloud Functions and the read-only Firestore
/// streams the UI listens to. Every write (user message, AI response, admin
/// claim/reply/close) goes through a Cloud Function — firestore.rules denies
/// all client writes to `supportChats`, so this service is the only path in.
class SupportChatService {
  final _functions = FirebaseFunctions.instance;
  final _db = FirebaseFirestore.instance;

  /// Sends a message in a support chat, creating one if [chatId] is null.
  /// Returns the chat id (unchanged from [chatId] if one was passed).
  Future<String> sendMessage({String? chatId, required String message}) async {
    try {
      final result = await _functions.httpsCallable('sendSupportMessage').call<Map<String, dynamic>>({
        'chatId': ?chatId,
        'message': message,
      });
      return result.data['chatId'] as String;
    } on FirebaseFunctionsException catch (e) {
      throw SupportChatException(e.message ?? 'Could not send your message.');
    }
  }

  /// Admin claims a chat that's waiting for a human — Claude stops being
  /// called for it and replies go through [sendAdminReply] from then on.
  Future<void> claimChat(String chatId) async {
    try {
      await _functions.httpsCallable('claimSupportChat').call<Map<String, dynamic>>({'chatId': chatId});
    } on FirebaseFunctionsException catch (e) {
      throw SupportChatException(e.message ?? 'Could not claim this conversation.');
    }
  }

  Future<void> sendAdminReply(String chatId, String message) async {
    try {
      await _functions.httpsCallable('sendAdminReply').call<Map<String, dynamic>>({
        'chatId': chatId,
        'message': message,
      });
    } on FirebaseFunctionsException catch (e) {
      throw SupportChatException(e.message ?? 'Could not send your reply.');
    }
  }

  Future<void> closeChat(String chatId) async {
    try {
      await _functions.httpsCallable('closeSupportChat').call<Map<String, dynamic>>({'chatId': chatId});
    } on FirebaseFunctionsException catch (e) {
      throw SupportChatException(e.message ?? 'Could not close this conversation.');
    }
  }

  /// The signed-in user's own support chats, most recent first.
  Stream<QuerySnapshot<Map<String, dynamic>>> myChats() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    return _db
        .collection('supportChats')
        .where('userId', isEqualTo: uid)
        .orderBy('lastMessageAt', descending: true)
        .snapshots();
  }

  /// Chats waiting for or currently being handled by a human, most recently
  /// active first — the admin support queue.
  Stream<QuerySnapshot<Map<String, dynamic>>> chatsNeedingAttention() {
    return _db
        .collection('supportChats')
        .where('status', whereIn: ['needs_human', 'human_active'])
        .orderBy('lastMessageAt', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> messages(String chatId) {
    return _db
        .collection('supportChats')
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt')
        .snapshots();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> chat(String chatId) {
    return _db.collection('supportChats').doc(chatId).snapshots();
  }
}
