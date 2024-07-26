import 'package:chat_app/service/auth_service.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _loginMailId = TextEditingController();
  final _password = TextEditingController();
  AuthService _auth = AuthService();
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
            Text("User Id"),
            TextField(
              controller: _loginMailId,
            ),
            Text("Password"),
            TextField(
              controller: _password,
            ),
            Text("Confirm Password"),
            TextField(
              controller: _password,
            ),
            TextButton(
                onPressed: () async {
                  await _auth.signUpWithUserId(
                    _loginMailId.text,
                    _password.text,
                  );
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Register"),
                    SizedBox(
                      width: 20,
                    ),
                    Icon(Icons.login)
                  ],
                ))
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
}
