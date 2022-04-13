import 'package:flutter/material.dart';
import 'package:notes/constants/routes.dart';
import 'package:notes/services/auth/auth_exceptions.dart';
import 'package:notes/services/auth/auth_service.dart';
import 'package:notes/utilities/show_error_dialog.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({Key? key}) : super(key: key);

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
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
      appBar: AppBar(title: const Text("register")),
      body: Column(
        children: [
          TextField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            enableSuggestions: false,
            autocorrect: false,
            decoration: const InputDecoration(hintText: "Enter you email here"),
          ),
          TextField(
            controller: _password,
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
            decoration: const InputDecoration(hintText: "Enter your password here"),
          ),
          TextButton(
            onPressed: () async {
              final email = _email.text;
              final password = _password.text;
              try {
                await AuthService.firebase().createUser(email: email, password: password);

                await AuthService.firebase().sendEmailVerification();

                Navigator.of(context).pushNamed(verifyEmailRoute);
              } on EmailAlreadyInUseAuthException {
                await showErrorDialog(context, "Email already in use ");
              } on InvalidEmailAuthException {
                await showErrorDialog(context, "Invalid email ");
              } on WeakPasswordAuthException {
                await showErrorDialog(context, "Weak password ");
              }
            },
            child: const Text("Register"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
              loginRoute,
              (_) => false,
            ),
            child: const Text("Already registered? Login Here"),
          ),
        ],
      ),
    );
  }
}
