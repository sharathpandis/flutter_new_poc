import 'dart:async';

import 'package:chat_app/service/auth_service.dart';
import 'package:chat_app/service/chat_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NewChatScreen extends StatefulWidget {
  final String userId;
  final String userEmail;
  const NewChatScreen({
    super.key,
    required this.userId,
    required this.userEmail,
  });

  @override
  State<NewChatScreen> createState() => _NewChatScreenState();
}

class _NewChatScreenState extends State<NewChatScreen> {
  final ScrollController _scrollController = ScrollController();
  final _messageCntrl = TextEditingController();
  final _firestore = FirebaseFirestore.instance;
  ChatService _chatService = ChatService();
  AuthService _auth = AuthService();
  List<QueryDocumentSnapshot> _messages = [];
  DocumentSnapshot? _lastDocument;
  bool _isFetching = false;
  String senderId = "";
  final StreamController<List<QueryDocumentSnapshot<Object?>>>
      _messagesController =
      StreamController<List<QueryDocumentSnapshot<Object?>>>();
  @override
  void initState() {
    super.initState();
    // _delayed();
    // _scrollController.addListener(_scrollListener);
    senderId = _auth.getCurrrentUser().uid;
    _fetchMessages(widget.userId, senderId);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // void _scrollListener() {
  //   if (_scrollController.position.pixels <= 100 && _lastDocument != null) {
  //     if (!_isFetching) {
  //       _fetchOlderMessages(widget.userId, senderId);
  //     }
  //   }
  // }

  Future<void> _delayed() async {
    await Future.delayed(
      const Duration(milliseconds: 500),
      () => scrollDown(),
    );
  }

  void scrollDown() {
    // _scrollController.animateTo(
    //   _scrollController.position.maxScrollExtent,
    //   duration: Duration(seconds: 1),
    //   curve: Curves.fastOutSlowIn,
    // );
    _scrollController.jumpTo(
      _scrollController.position.maxScrollExtent,
    );
  }

  Future<void> _fetchMessages(String userId, senderId) async {
    print("fetching messages");
    List<String> ids = [userId, senderId];
    ids.sort();
    String chatRoomId = ids.join('_');
    QuerySnapshot snapshot = await _firestore
        .collection("chat_rooms")
        .doc(chatRoomId)
        .collection("messages")
        .orderBy('timestamp', descending: true)
        .limit(20)
        .get();

    setState(() {
      _messages = snapshot.docs;
      _lastDocument = snapshot.docs.last;
    });
    _messagesController.add(_messages);
  }

  Future<void> _fetchOlderMessages(String userId, senderId) async {
    print("fetching older messages");
    setState(() {
      _isFetching = true;
    });
    List<String> ids = [userId, senderId];
    ids.sort();
    String chatRoomId = ids.join('_');
    QuerySnapshot snapshot = await _firestore
        .collection("chat_rooms")
        .doc(chatRoomId)
        .collection("messages")
        .orderBy('timestamp', descending: true)
        .startAfterDocument(_lastDocument!)
        .limit(20)
        .get();

    setState(() {
      _messages.addAll(snapshot.docs);
      _lastDocument = snapshot.docs.last;
      _isFetching = false;
    });
    _messagesController.add(_messages);
  }

  void sendMessage() async {
    if (_messageCntrl.text.isNotEmpty) {
      // for (var i = 0; i < 800; i++) {
      //     await _chatService.sendMessage(widget.userId, _messageCntrl.text);
      // }
      await _chatService.sendMessage(widget.userId, _messageCntrl.text);
      _messageCntrl.clear();
      senderId = _auth.getCurrrentUser().uid;
      _fetchMessages(widget.userId, senderId);
      // scrollDown();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat'),
      ),
      // body: Column(
      //   children: [
      //     Expanded(
      //       child: ListView.builder(
      //         controller: _scrollController,
      //         itemCount: _messages.length,
      //         itemBuilder: (context, index) {
      //           return buildItem(_messages[index]);
      //         },
      //       ),
      //     ),
      //     // Add your input field for sending messages
      //   ],
      // ),
      body: Column(
        children: [
          Expanded(
            child: NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification scrollInfo) {
                if (scrollInfo.metrics.pixels ==
                        scrollInfo.metrics.maxScrollExtent &&
                    !_isFetching) {
                  _fetchOlderMessages(widget.userId, senderId);
                }
                return false;
              },
              // child: ListView.builder(
              //   reverse: true,
              //   itemCount: _messages.length,
              //   itemBuilder: (context, index) {
              //     return buildItem(_messages[index]);
              //   },
              // ),
              child: StreamBuilder(
                stream: _messagesController.stream,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  return ListView.builder(
                    reverse: true, // For chat-like behavior (newest at bottom)
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return buildItem(_messages[index]);
                    },
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(28.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageCntrl,
                    onChanged: (value) {},
                    decoration: InputDecoration(
                        contentPadding:
                            const EdgeInsets.fromLTRB(10, 10, 10, 10),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8))),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                CircleAvatar(
                  backgroundColor: Colors.blueAccent,
                  child: IconButton(
                    color: Colors.white,
                    onPressed: sendMessage,
                    icon: const Icon(Icons.arrow_upward),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget buildItem(DocumentSnapshot doc) {
    Map<String, dynamic> document = doc.data() as Map<String, dynamic>;
    bool isCurrentUser = document["senderId"] == _auth.getCurrrentUser().uid;

    var alignment =
        isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment:
            isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isCurrentUser
                        ? Color.fromARGB(255, 55, 160, 109)
                        : Colors.blueGrey,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    document["message"],
                    style: TextStyle(color: Colors.white),
                  )),
            ],
          ),
        ],
      ),
    );
  }
}
