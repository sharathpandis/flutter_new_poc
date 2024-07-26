import 'package:chat_app/chat/chat_screen.dart';
import 'package:chat_app/service/auth_service.dart';
import 'package:chat_app/service/chat_service.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ChatService chatServices = ChatService();
  AuthService authService = AuthService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Chat List Screen"),
          actions: [
            IconButton(
              onPressed: () async {
                await authService.signOut();
              },
              icon: Icon(Icons.logout),
            )
          ],
        ),
        // body: Column(),
        body: StreamBuilder(
            stream: chatServices.getUsersStream(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Text("Error");
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              return ListView(
                children: snapshot.data!.map<Widget>((userdata) {
                  if (userdata["uid"] != authService.getCurrrentUser().uid) {
                    return UserTile(
                      userName: userdata["email"],
                      onTap: () {
                        _userClicked(userdata["email"], userdata["uid"]);
                      },
                    );
                  } else {
                    return SizedBox();
                  }
                }).toList(),
              );
            }));
  }

  void _userClicked(String userEmail, String userId) {
    final pageRoute = MaterialPageRoute(builder: (context) {
      return ChatScreen(
        userEmail: userEmail,
        userId: userId,
      );
    });
    Navigator.push(context, pageRoute);
  }
}

class UserTile extends StatelessWidget {
  final String userName;
  final void Function() onTap;
  const UserTile({
    super.key,
    required this.userName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onTap();
      },
      child: ListTile(
        leading: Icon(Icons.person),
        title: Text(userName),
      ),
      // child: Row(
      //   children: [Icon(Icons.person), Text(userName)],
      // ),
    );
  }
}
