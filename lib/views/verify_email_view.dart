import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notes/constants/routes.dart';
import 'package:notes/helpers/firebase_errors.dart';
import 'dart:developer' as devtools show log;

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
          const Text("If you did not find the email please chek the junk/spam box"),
          const Text("If you haven't received a verification email yet, press the button below"),
          TextButton(
            onPressed: () async {
              final user = FirebaseAuth.instance.currentUser;
              devtools.log(user.toString());
              try {
                await user?.sendEmailVerification();
              } on FirebaseAuthException catch (e) {
                firebaseError(context, e.code);
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
