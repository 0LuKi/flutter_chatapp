import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chatapp/components/chat_bubble.dart';
import 'package:flutter_chatapp/components/my_textfield.dart';
import 'package:flutter_chatapp/services/auth/chat/chat_service.dart';

class ChatPage extends StatefulWidget {
  final String receiverUserEmail;
  final String receiverUserID;
  const ChatPage({
    super.key,
    required this.receiverUserEmail,
    required this.receiverUserID
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {

  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  void sendMessage() async {
    // only send message if it's not empty
    if (_messageController.text.isNotEmpty) {
      await _chatService.sendMessage(
        widget.receiverUserID, _messageController.text
      );
      // clear the controller after sending a messeage
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.receiverUserEmail),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
      ),
      body: Container(
        color: Colors.blue.shade50,
        child: Column(
          children: [
            Expanded(
              child: _buildMessageList(),
            ),
            _buildMessageInput()
          ]
        ),
      ),
    );
  }

  // build message list
  Widget _buildMessageList() {
    return StreamBuilder(
      stream: _chatService.getMessages(
        widget.receiverUserID, _firebaseAuth.currentUser!.uid),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;
        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final currentDoc = docs[index];
            final prevDoc = index > 0 ? docs[index - 1] : null;
            return _buildMessageItem(currentDoc, prevDoc);
          },
        );
      }
    );
  }



  // build message item
  Widget _buildMessageItem(DocumentSnapshot document, DocumentSnapshot? prevDocument) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    String currentSenderId = data['senderId'];

    String? prevSenderId;
    if (prevDocument != null && prevDocument.data() != null) {
      Map<String, dynamic> prevData = prevDocument.data() as Map<String, dynamic>;
      prevSenderId = prevData['senderId'];
    }

    bool showSenderName = prevSenderId != currentSenderId;

    var alignment = (currentSenderId == _firebaseAuth.currentUser!.uid)
        ? Alignment.centerRight
        : Alignment.centerLeft;

    return Container(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 12.0),
        child: Column(
          crossAxisAlignment: (currentSenderId == _firebaseAuth.currentUser!.uid)
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            if (showSenderName || prevSenderId == null)
              Padding(
                padding: const EdgeInsets.only(bottom: 2.0),
                child: Text(
                  data['senderEmail'],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                    fontSize: 13,
                  ),
                ),
              ),
            ChatBubble(
              message: data['message'],
              isMe: currentSenderId == _firebaseAuth.currentUser!.uid,
            ),
          ],
        ),
      ),
    );
  }


  // build messageinput
  Widget _buildMessageInput() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: MyTextField(
              controller: _messageController,
              hintText: "Type your message...",
              obscureText: false,
            ),
          ),
          SizedBox(width: 8),
          Material(
            color: Colors.blue.shade700,
            borderRadius: BorderRadius.circular(16),
            child: IconButton(
              onPressed: sendMessage,
              icon: Icon(Icons.send, color: Colors.white),
            ),
          ),
        ]
      ),
    );
  }
}