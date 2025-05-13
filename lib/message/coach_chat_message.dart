// Updated CoachChatScreen using Supabase instead of Firebase
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CoachChatScreen extends StatefulWidget {
  final String chatId;
  final String learnerId;
  final String learnerName;

  const CoachChatScreen({
    required this.chatId,
    required this.learnerId,
    required this.learnerName,
    super.key,
  });

  @override
  State<CoachChatScreen> createState() => _CoachChatScreenState();
}

class _CoachChatScreenState extends State<CoachChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final SupabaseClient _supabase = Supabase.instance.client;
  final ScrollController _scrollController = ScrollController();
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _markMessagesAsRead();
  }

  Future<void> _markMessagesAsRead() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    final response = await _supabase
        .from('messages')
        .select('id')
        .eq('chat_id', widget.chatId)
        .eq('sender_id', widget.learnerId)
        .eq('read', false);

    for (var msg in response) {
      await _supabase.from('messages').update({'read': true}).eq('id', msg['id']);
    }
  }

  Future<void> sendMessage() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null || _messageController.text.trim().isEmpty) return;

    setState(() => _isSending = true);
    final text = _messageController.text.trim();

    try {
      await _supabase.from('messages').insert({
        'chat_id': widget.chatId,
        'sender_id': userId,
        'text': text,
        'timestamp': DateTime.now().toIso8601String(),
        'type': 'text',
        'read': false,
      });

      await _supabase.from('chats').update({
        'last_message': text,
        'last_updated': DateTime.now().toIso8601String(),
      }).eq('id', widget.chatId);

      _messageController.clear();
      _scrollToBottom();
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to send: $e')));
    } finally {
      setState(() => _isSending = false);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget _buildMessageBubble(Map<String, dynamic> data) {
    final userId = _supabase.auth.currentUser?.id;
    final isMe = data['sender_id'] == userId;
    final time = DateTime.tryParse(data['timestamp'] ?? '') ?? DateTime.now();
    final timeString = DateFormat('h:mm a').format(time);

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isMe ? const Color.fromARGB(255, 255, 193, 7) : Colors.grey[200],
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(12),
              topRight: const Radius.circular(12),
              bottomLeft: isMe ? const Radius.circular(12) : Radius.zero,
              bottomRight: isMe ? Radius.zero : const Radius.circular(12),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data['text'] ?? '',
                style: TextStyle(color: isMe ? Colors.black : Colors.black87),
              ),
              const SizedBox(height: 4),
              Text(
                timeString,
                style: TextStyle(
                  color: isMe ? Colors.black54 : Colors.grey[600],
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.learnerName),
        backgroundColor: const Color.fromARGB(255, 255, 193, 7),
        actions: [
          IconButton(
            icon: const Icon(Icons.video_call),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _supabase
                  .from('messages')
                  .stream(primaryKey: ['id'])
                  .eq('chat_id', widget.chatId)
                  .order('timestamp', ascending: true),
              builder: (context, snapshot) {
                final data = snapshot.data;

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (data == null || data.isEmpty) {
                  return const Center(
                    child: Text('Start your conversation with the learner'),
                  );
                }

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToBottom();
                });

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(8),
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    return _buildMessageBubble(data[index]);
                  },
                );
              },
            ),
          ),
          if (_isSending) const LinearProgressIndicator(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.attach_file),
                  onPressed: () {},
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    maxLines: 3,
                    minLines: 1,
                    onSubmitted: (_) => sendMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  color: const Color.fromARGB(255, 255, 193, 7),
                  onPressed: sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
