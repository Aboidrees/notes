import 'package:flutter/material.dart';
import 'package:notes/constants/routes.dart';
import 'package:notes/services/auth/auth_exceptions.dart';
import 'package:notes/services/auth/auth_service.dart';
import 'package:notes/utilities/dialogs/error_dialog.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 100),
            TextField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              enableSuggestions: false,
              autocorrect: false,
              decoration: InputDecoration(hintText: "Enter you email here", border: myInputBorder()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _password,
              obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
              decoration: InputDecoration(hintText: "Enter your password here", border: myInputBorder()),
            ),
            TextButton(
              onPressed: () async {
                final email = _email.text;
                final password = _password.text;
                try {
                  await AuthService.firebase().logIn(email: email, password: password);
                  final user = AuthService.firebase().currentUser;
                  if (user?.isEmailVerified ?? false) {
                    Navigator.of(context).pushNamedAndRemoveUntil(notesRoute, (_) => false);
                  } else {
                    Navigator.of(context).pushNamedAndRemoveUntil(verifyEmailRoute, (_) => false);
                  }
                } on InvalidEmailAuthException {
                  await showErrorDialog(context, "Invalid email");
                } on UserNotFoundAuthException {
                  await showErrorDialog(context, "User not found");
                } on WrongPasswordAuthException {
                  await showErrorDialog(context, "Wrong credentials");
                } on GenericAuthException {
                  showErrorDialog(context, "Authentication Error");
                }
              },
              child: const Text("Login"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(registerRoute, (_) => false),
              child: const Text("Not registered yet? Register Here"),
            ),
          ],
        ),
      ),
    );
  }
}

myInputBorder() {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(30),
    borderSide: const BorderSide(
      color: Colors.grey,
      style: BorderStyle.solid,
      width: 3,
    ),
  );
}
