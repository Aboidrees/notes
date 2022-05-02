import 'package:flutter/material.dart';
import 'package:notes/constants/routes.dart';
import 'package:notes/services/auth/auth_exceptions.dart';
import 'package:notes/services/auth/auth_service.dart';
import 'package:notes/utilities/dialogs/error_dialog.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({Key? key}) : super(key: key);

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Verify Email")),
      body: Column(
        children: [
          const Text("We've sent you an email verification. Please open it"),
          const Text("If you did not find the email please check the junk/spam box"),
          const Text("If you haven't received a verification email yet, press the button below"),
          TextButton(
            onPressed: () async {
              try {
                AuthService.firebase().sendEmailVerification();
              } on GenericAuthException {
                showErrorDialog(context, "Can not send verification email");
              }
            },
            child: const Text("Resend Verification Email"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(loginRoute, (_) => false),
            child: const Text("Or Proceed to Login"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(registerRoute, (_) => false),
            child: const Text("Restart Registration"),
          ),
        ],
      ),
    );
  }
}
