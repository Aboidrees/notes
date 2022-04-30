import 'package:flutter/material.dart';
import 'package:notes/utilities/dialogs/show_generic_dialog.dart';

Future<bool> showDeleteDialog(BuildContext context) {
  return showGenericDialog<bool>(
    context: context,
    title: "Delete",
    content: "Are you sure you want to delete this item?",
    optionBuilder: () => {
      "yes": true,
      "No": false,
    },
  ).then((value) => value ?? false);
}
