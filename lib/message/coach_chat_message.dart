import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ScrollController _scrollController = ScrollController();
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _markMessagesAsRead();
  }

  void _markMessagesAsRead() async {
    await _firestore
        .collection('chats')
        .doc(widget.chatId)
        .collection('messages')
        .where('senderId', isEqualTo: widget.learnerId)
        .where('read', isEqualTo: false)
        .get()
        .then((snapshot) {
          final batch = _firestore.batch();
          for (final doc in snapshot.docs) {
            batch.update(doc.reference, {'read': true});
          }
          return batch.commit();
        });
  }

  Future<void> sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    setState(() => _isSending = true);
    final String currentUserId = _auth.currentUser!.uid;
    final String text = _messageController.text.trim();

    try {
      // Add message to messages subcollection
      await _firestore
          .collection('chats')
          .doc(widget.chatId)
          .collection('messages')
          .add({
            'senderId': currentUserId,
            'text': text,
            'timestamp': FieldValue.serverTimestamp(),
            'type': 'text',
            'read': false,
          });

      // Update chat metadata
      await _firestore.collection('chats').doc(widget.chatId).update({
        'lastMessage': text,
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      _messageController.clear();
      _scrollToBottom();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to send: $e')));
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

  Widget _buildMessageBubble(DocumentSnapshot message) {
    final data = message.data() as Map<String, dynamic>;
    final isMe = data['senderId'] == _auth.currentUser!.uid;
    final timestamp = data['timestamp'] as Timestamp?;
    final timeString =
        timestamp != null
            ? DateFormat('h:mm a').format(timestamp.toDate())
            : '';

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
            color:
                isMe
                    ? const Color.fromARGB(255, 255, 193, 7)
                    : Colors.grey[200],
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
                data['text'],
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.learnerName),
            StreamBuilder<DocumentSnapshot>(
              stream:
                  _firestore
                      .collection('users')
                      .doc(widget.learnerId)
                      .snapshots(),
              builder: (context, snapshot) {
                final status = snapshot.data?['status'] ?? 'offline';
                return Text(
                  status == 'online' ? 'Online' : 'Offline',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: status == 'online' ? Colors.green : Colors.grey,
                  ),
                );
              },
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.video_call),
            onPressed: () {
              // Implement video call functionality
            },
          ),
        ],
        backgroundColor: const Color.fromARGB(255, 255, 193, 7),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  _firestore
                      .collection('chats')
                      .doc(widget.chatId)
                      .collection('messages')
                      .orderBy('timestamp', descending: false)
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
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
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    return _buildMessageBubble(snapshot.data!.docs[index]);
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
                  onPressed: () {
                    // Implement file attachment
                  },
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
