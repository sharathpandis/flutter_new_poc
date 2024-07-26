import 'package:chat_app/register_screen.dart';
import 'package:chat_app/service/auth_service.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _loginMailId = TextEditingController();
  final _password = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login Screen"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          children: [
            Text("Login Id"),
            TextField(
              controller: _loginMailId,
            ),
            Text("Password"),
            TextField(
              controller: _password,
            ),
            TextButton(
              onPressed: () {
                _loginClicked(_loginMailId.text, _password.text);
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Login"),
                  SizedBox(
                    width: 20,
                  ),
                  Icon(Icons.login)
                ],
              ),
            ),
            Text("Or"),
            TextButton(
              onPressed: _registerClicked,
              child: Text("Register"),
            )
          ],
        ),
      ),
    );
  }

  void _registerClicked() {
    final pageRoute = MaterialPageRoute(builder: (context) {
      return RegisterScreen();
    });
    Navigator.push(context, pageRoute);
  }

  void _loginClicked(String emailId, String password) async {
    final service = AuthService();
    try {
      await service.signInWithUserId(emailId, password);
    } catch (e) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(e.toString()),
            );
          });
    }
  }
}
