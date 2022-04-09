import 'package:flutter/material.dart';
import 'package:notes/utilities/show_error_dialog.dart';

void firebaseError(BuildContext context, String code) async {
  switch (code) {
    case "user-not-found":
      await showErrorDialog(context, "User not found!");
      break;

    case "wrong-password":
      await showErrorDialog(context, "Wrong credentials!");
      break;

    case "email-already-in-use":
      await showErrorDialog(context, "Email already in use!");
      break;

    case "invalid-email":
      await showErrorDialog(context, "Invalide email!");
      break;

    case "weak-password-found":
      await showErrorDialog(context, "Weak password, consider to use strong password!");
      break;

    default:
      await showErrorDialog(context, "Unknown error, contact support!");
  }
}
