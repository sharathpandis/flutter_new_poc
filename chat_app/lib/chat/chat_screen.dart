import 'package:chat_app/service/auth_service.dart';
import 'package:chat_app/service/chat_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatScreenView extends StatefulWidget {
  final String userId;
  final String userEmail;
  const ChatScreenView({
    super.key,
    required this.userId,
    required this.userEmail,
  });

  @override
  State<ChatScreenView> createState() => _ChatScreenViewState();
}

class _ChatScreenViewState extends State<ChatScreenView> {
  final _messageCntrl = TextEditingController();
  AuthService _auth = AuthService();
  ChatService _chatService = ChatService();
  FocusNode myFocusnode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  double _scrollPosition = 0;
  bool _typing = false;
  bool _isFetchongMore = false;
  int _msgCount = 20;
  List<QueryDocumentSnapshot<Object?>> messages = [];
  List<QueryDocumentSnapshot<Object?>> recentMessages = [];
  DocumentSnapshot? _lastDocument;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    myFocusnode.addListener(() {
      if (myFocusnode.hasFocus) {
        _delayed();
      }
    });
    _delayed();
    // _scrollController.addListener(_scrollListener);
  }

  Future<void> _delayed() async {
    await Future.delayed(
      const Duration(milliseconds: 500),
      () => scrollDown(),
    );
  }

  void scrollDown() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(seconds: 1),
      curve: Curves.fastOutSlowIn,
    );
  }

  // _scrollListener() {
  //   _scrollPosition = _scrollController.position.pixels;
  //   if (_scrollPosition == _scrollController.position.minScrollExtent &&
  //       _lastDocument != null) {
  //     setState(() {});
  //   }
  // }
  void _fetchMore() {
    print("isfetching");
    setState(() {
      _isFetchongMore = true;
    });
    String senderId = _auth.getCurrrentUser().uid;
    _chatService.getMessages(widget.userId, senderId, _msgCount, _lastDocument);
    setState(() {
      _isFetchongMore = false;
    });
  }

  @override
  void dispose() {
    myFocusnode.dispose();
    _messageCntrl.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void sendMessage() async {
    if (_messageCntrl.text.isNotEmpty) {
      // for (var i = 0; i < 800; i++) {
      //     await _chatService.sendMessage(widget.userId, _messageCntrl.text);
      // }
      await _chatService.sendMessage(widget.userId, _messageCntrl.text);
      _messageCntrl.clear();

      scrollDown();
    }
  }

  @override
  Widget build(BuildContext context) {
    String senderId = _auth.getCurrrentUser().uid;
    print("new message added1");
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.userEmail),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: _chatService.getMessages(
                  widget.userId, senderId, _msgCount, _lastDocument),
              builder: (context, snapshot) {
                print("new message added");
                if (snapshot.hasError) {
                  return const Center(
                    child: Text("Error Message"),
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                // return ListView(
                //   controller: _scrollController,
                //   children: snapshot.data!.docs.map((doc) {
                //     return buildItem(doc);
                //   }).toList(),
                // );
                // messages.addAll(snapshot.data!.docs);
                if (_lastDocument == null) {
                  recentMessages = snapshot.data!.docs;
                  messages = recentMessages;
                }
                if (_lastDocument != null) {
                  messages = [];
                  List<QueryDocumentSnapshot<Object?>> oldMessages =
                      snapshot.data!.docs;

                  messages.addAll(oldMessages);
                  // messages.addAll(recentMessages);
                }
                _lastDocument = snapshot.data!.docs.last;
                return NotificationListener<ScrollNotification>(
                  onNotification: (ScrollNotification scrollInfo) {
                    if (scrollInfo.metrics.pixels ==
                            scrollInfo.metrics.maxScrollExtent &&
                        !_isFetchongMore) {
                      _fetchMore();
                    }
                    return false;
                  },
                  child: ListView.builder(
                    reverse: true,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      return buildItem(messages[index]);
                    },
                  ),
                );
                // return ListView.builder(
                //   controller: _scrollController,
                //   itemCount: messages.length,
                //   itemBuilder: (context, index) {
                //     return buildItem(messages[index]);
                //   },
                // );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(28.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    focusNode: myFocusnode,
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
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
