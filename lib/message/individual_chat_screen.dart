import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class IndividualChatScreen extends StatefulWidget {
  final String chatId;
  final String otherUserId;
  final String otherUserName;
  final bool isCoach;

  const IndividualChatScreen({
    super.key,
    required this.chatId,
    required this.otherUserId,
    required this.otherUserName,
    required this.isCoach,
  });

  @override
  State<IndividualChatScreen> createState() => _IndividualChatScreenState();
}

class _IndividualChatScreenState extends State<IndividualChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _markMessagesAsRead();
  }

  void _markMessagesAsRead() async {
    final messages =
        await _firestore
            .collection('chats')
            .doc(widget.chatId)
            .collection('messages')
            .where('senderId', isEqualTo: widget.otherUserId)
            .where('read', isEqualTo: false)
            .get();

    final batch = _firestore.batch();
    for (final doc in messages.docs) {
      batch.update(doc.reference, {'read': true});
    }
    await batch.commit();
  }

  Future<void> sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    // Add message to Firestore
    await _firestore
        .collection('chats')
        .doc(widget.chatId)
        .collection('messages')
        .add({
          'senderId': _auth.currentUser!.uid,
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

  @override
  Widget build(BuildContext context) {
    final currentUserId = _auth.currentUser!.uid;
    final coachBubbleColor = const Color.fromARGB(255, 255, 193, 7);
    final individualBubbleColor = Colors.grey[200];

    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with ${widget.otherUserName}'),
        backgroundColor: widget.isCoach ? coachBubbleColor : Colors.blue,
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
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!.docs;

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToBottom();
                });

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(10),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message['senderId'] == currentUserId;
                    final timestamp = message['timestamp'] as Timestamp?;
                    final timeString =
                        timestamp != null
                            ? DateFormat('h:mm a').format(timestamp.toDate())
                            : '';

                    return Align(
                      alignment:
                          isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.75,
                        ),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color:
                              isMe
                                  ? (widget.isCoach
                                      ? coachBubbleColor
                                      : Colors.blue)
                                  : individualBubbleColor,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(12),
                            topRight: const Radius.circular(12),
                            bottomLeft:
                                isMe ? const Radius.circular(12) : Radius.zero,
                            bottomRight:
                                isMe ? Radius.zero : const Radius.circular(12),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              message['text'],
                              style: TextStyle(
                                color: isMe ? Colors.white : Colors.black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              timeString,
                              style: TextStyle(
                                color: isMe ? Colors.white70 : Colors.grey[600],
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                    ),
                    onSubmitted: (_) => sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(
                    Icons.send,
                    color: widget.isCoach ? coachBubbleColor : Colors.blue,
                  ),
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
