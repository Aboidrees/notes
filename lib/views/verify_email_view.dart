import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notes/services/auth/bloc/auth_bloc.dart';
import 'package:notes/services/auth/bloc/auth_event.dart';

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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 100),
            const Text(
              "We've sent you an email verification. Please open it",
              style: TextStyle(fontSize: 16.0),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8.0),
            const Text(
              "If you did not find the email please check the junk/spam box",
              style: TextStyle(fontSize: 16.0),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8.0),
            const Text(
              "If you haven't received a verification email yet, press the button below",
              style: TextStyle(fontSize: 16.0),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16.0),
            TextButton(
              onPressed: () async {
                context.read<AuthBloc>().add(const AuthEventSendEmailVerification());
              },
              child: const Text("Resend Verification Email"),
            ),
            TextButton(
              onPressed: () => context.read<AuthBloc>().add(const AuthEventLogOut()),
              child: const Text("Restart"),
            ),
          ],
        ),
      ),
    );
  }
}
