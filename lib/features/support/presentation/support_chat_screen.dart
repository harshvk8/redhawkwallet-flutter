import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/support_chat_service.dart';
import '../widgets/support_message_bubble.dart';

/// Entry point for Help & Support. Resumes the user's most recent open
/// conversation (if any) instead of always starting fresh — otherwise
/// re-opening this screen after an AI escalated to a human, or mid-reply,
/// would silently abandon that conversation and start a new AI-handled one.
class SupportChatScreen extends StatefulWidget {
  const SupportChatScreen({super.key});

  @override
  State<SupportChatScreen> createState() => _SupportChatScreenState();
}

class _SupportChatScreenState extends State<SupportChatScreen> {
  final _service = SupportChatService();
  // Set immediately after this device creates a brand-new chat, so the UI
  // switches over without waiting a round-trip for `myChats()` to reflect it.
  String? _justCreatedChatId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help & Support'), elevation: 0),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _service.myChats(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            final cs = Theme.of(context).colorScheme;
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline, color: cs.error, size: 40),
                    const SizedBox(height: 12),
                    Text(
                      'Could not load Help & Support.\n${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton(onPressed: () => setState(() {}), child: const Text('Retry')),
                  ],
                ),
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data!.docs;
          final mostRecent = docs.isNotEmpty ? docs.first : null;
          final mostRecentIsOpen = mostRecent != null && mostRecent.data()['status'] != 'closed';
          final activeChatId = _justCreatedChatId ?? (mostRecentIsOpen ? mostRecent.id : null);

          return _ChatBody(
            key: ValueKey(activeChatId ?? 'new'),
            chatId: activeChatId,
            onChatCreated: (id) => setState(() => _justCreatedChatId = id),
          );
        },
      ),
    );
  }
}

class _ChatBody extends StatefulWidget {
  const _ChatBody({super.key, required this.chatId, required this.onChatCreated});
  final String? chatId;
  final ValueChanged<String> onChatCreated;

  @override
  State<_ChatBody> createState() => _ChatBodyState();
}

class _ChatBodyState extends State<_ChatBody> {
  final _service = SupportChatService();
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();
  bool _sending = false;
  String? _error;

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _inputController.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() {
      _sending = true;
      _error = null;
    });
    _inputController.clear();
    try {
      final chatId = await _service.sendMessage(chatId: widget.chatId, message: text);
      if (widget.chatId == null) widget.onChatCreated(chatId);
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    } on SupportChatException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _scrollToBottom() {
    if (!mounted || !_scrollController.hasClients) return;
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: [
        Expanded(
          child: widget.chatId == null
              ? _WelcomeState(cs: cs)
              : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: _service.messages(widget.chatId!),
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
                          sender: data['sender'] as String? ?? 'assistant',
                          text: data['text'] as String? ?? '',
                        );
                      },
                    );
                  },
                ),
        ),
        if (_error != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.red.withValues(alpha: 0.1),
            child: Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 12)),
          ),
        if (_sending)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(strokeWidth: 2, color: cs.primary),
                ),
                const SizedBox(width: 8),
                Text('Thinking…', style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
              ],
            ),
          ),
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
                    onSubmitted: (_) => _send(),
                    decoration: InputDecoration(
                      hintText: 'Ask about the app…',
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
                  onPressed: _sending ? null : _send,
                  icon: const Icon(Icons.send),
                  style: IconButton.styleFrom(backgroundColor: cs.primary, foregroundColor: cs.onPrimary),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _WelcomeState extends StatelessWidget {
  const _WelcomeState({required this.cs});
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: cs.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(Icons.support_agent, color: cs.primary, size: 48),
            ),
            const SizedBox(height: 20),
            Text(
              "Hi! I'm the Red Hawk Wallet assistant.",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: cs.onSurface),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Ask me how to use the app, or describe a problem you ran into — I can bring in a team member if you need one.',
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
