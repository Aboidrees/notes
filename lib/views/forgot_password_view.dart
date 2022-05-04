import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notes/services/auth/bloc/auth_bloc.dart';
import 'package:notes/services/auth/bloc/auth_event.dart';
import 'package:notes/services/auth/bloc/auth_state.dart';
import 'package:notes/utilities/dialogs/error_dialog.dart';
import 'package:notes/utilities/dialogs/password_reset_email_sent_dialog.dart';
import 'package:notes/utilities/styles.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  late final TextEditingController _controller;

  @override
  void initState() {
    _controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateForgotPassword) {
          if (state.emailSent) {
            _controller.clear();
            await showPasswordResetSentDialog(context);
          }

          if (state.exception != null) {
            await showErrorDialog(context,
                """We could not process your request. Please make sure that you entered the correct email if you are a registered user, or if not, register now account by going back one step.""");
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Reset Password"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 100),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "If you forgot your password, simply enter your email and we will send you a password reset link",
                    style: TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  autofocus: true,
                  controller: _controller,
                  decoration: InputDecoration(hintText: "Enter you email here", border: myInputBorder()),
                ),
                TextButton(
                  onPressed: () {
                    final email = _controller.text;
                    context.read<AuthBloc>().add(AuthEventForgotPassword(email: email));
                  },
                  child: const Text("Send password reset link"),
                ),
                TextButton(
                  onPressed: () => context.read<AuthBloc>().add(const AuthEventLogOut()),
                  child: const Text("Back to login"),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
