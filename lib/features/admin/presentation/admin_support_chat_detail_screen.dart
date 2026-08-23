import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../support/services/support_chat_service.dart';
import '../../support/widgets/support_message_bubble.dart';

class AdminSupportChatDetailScreen extends StatefulWidget {
  const AdminSupportChatDetailScreen({super.key, required this.chatId});
  final String chatId;

  @override
  State<AdminSupportChatDetailScreen> createState() => _AdminSupportChatDetailScreenState();
}

class _AdminSupportChatDetailScreenState extends State<AdminSupportChatDetailScreen> {
  final _service = SupportChatService();
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();
  bool _busy = false;

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (!mounted || !_scrollController.hasClients) return;
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  Future<void> _claim() async {
    setState(() => _busy = true);
    try {
      await _service.claimChat(widget.chatId);
    } on SupportChatException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _reply() async {
    final text = _inputController.text.trim();
    if (text.isEmpty || _busy) return;
    setState(() => _busy = true);
    _inputController.clear();
    try {
      await _service.sendAdminReply(widget.chatId, text);
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    } on SupportChatException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _close() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Close conversation?'),
        content: const Text('The student can still send a new message afterward — it will start a fresh AI-handled conversation.'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Close'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await _service.closeChat(widget.chatId);
      if (mounted) Navigator.of(context).pop();
    } on SupportChatException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: _service.chat(widget.chatId),
      builder: (context, chatSnapshot) {
        final chatData = chatSnapshot.data?.data();
        final status = chatData?['status'] as String?;
        final assignedAdminId = chatData?['assignedAdminId'] as String?;
        final userName = chatData?['userName'] as String? ?? 'Student';
        final isMine = assignedAdminId == _uid;
        final canReply = status == 'human_active' && isMine;
        final canClaim = status == 'needs_human' || (status == 'human_active' && !isMine);

        return Scaffold(
          appBar: AppBar(
            title: Text(userName),
            elevation: 0,
            actions: [
              if (status == 'human_active' && isMine)
                IconButton(icon: const Icon(Icons.check_circle_outline), tooltip: 'Close conversation', onPressed: _close),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: _service.messages(widget.chatId),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            'Could not load this conversation.\n${snapshot.error}',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
                          ),
                        ),
                      );
                    }
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final docs = snapshot.data!.docs;
                    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final data = docs[index].data();
                        return SupportMessageBubble(
                          sender: data['sender'] as String? ?? 'user',
                          text: data['text'] as String? ?? '',
                          alignRight: 'admin',
                        );
                      },
                    );
                  },
                ),
              ),
              if (canClaim)
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _busy ? null : _claim,
                        icon: const Icon(Icons.support_agent),
                        label: Text(status == 'human_active' ? 'Take over conversation' : 'Claim conversation'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: cs.primary,
                          foregroundColor: cs.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ),
                )
              else if (canReply)
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _inputController,
                            minLines: 1,
                            maxLines: 4,
                            textInputAction: TextInputAction.send,
                            onSubmitted: (_) => _reply(),
                            decoration: InputDecoration(
                              hintText: 'Reply…',
                              filled: true,
                              fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.4),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton.filled(
                          onPressed: _busy ? null : _reply,
                          icon: const Icon(Icons.send),
                          style: IconButton.styleFrom(backgroundColor: cs.primary, foregroundColor: cs.onPrimary),
                        ),
                      ],
                    ),
                  ),
                )
              else if (status == 'closed')
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('This conversation is closed.', style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13)),
                ),
            ],
          ),
        );
      },
    );
  }
}
