import 'package:flutter/material.dart';
import "package:flutter_bloc/flutter_bloc.dart";
import 'package:notes/services/auth/auth_exceptions.dart';
import 'package:notes/services/auth/bloc/auth_bloc.dart';
import 'package:notes/services/auth/bloc/auth_event.dart';
import 'package:notes/services/auth/bloc/auth_state.dart';
import 'package:notes/utilities/dialogs/error_dialog.dart';
import 'package:notes/utilities/dialogs/loading_dialog.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  CloseDialog? _closeDialogHandle;

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
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateLoggedOut) {
          final closeDialog = _closeDialogHandle;

          if (!state.isLoading && closeDialog != null) {
            closeDialog();
            _closeDialogHandle = null;
          } else if (state.isLoading && closeDialog == null) {
            _closeDialogHandle = showLoadingDialog(context: context, text: "Loading...");
          }

          if (state.exception is UserNotFoundAuthException) {
            await showErrorDialog(context, "User not found");
          } else if (state.exception is WrongPasswordAuthException) {
            await showErrorDialog(context, "Wrong credentials");
          } else if (state.exception is InvalidEmailAuthException) {
            await showErrorDialog(context, "Invalid email");
          } else if (state.exception is GenericAuthException) {
            await showErrorDialog(context, "Authentication Error");
          }
        }
      },
      child: Scaffold(
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
                  context.read<AuthBloc>().add(AuthEventLogIn(_email.text, _password.text));
                },
                child: const Text("Login"),
              ),
              TextButton(
                onPressed: () => context.read<AuthBloc>().add(const AuthEventShouldRegister()),
                child: const Text("Not registered yet? Register Here"),
              ),
            ],
          ),
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
