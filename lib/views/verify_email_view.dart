// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({Key? key}) : super(key: key);

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text("Please, verify your email address"),
        TextButton(
          onPressed: () async {
            final user = FirebaseAuth.instance.currentUser;
            print(user);
            try {
              await user?.sendEmailVerification();
            } catch (e) {
              print(e);
            }
          },
          child: const Text("Send Email Verification"),
        ),
      ],
    );
  }
}
