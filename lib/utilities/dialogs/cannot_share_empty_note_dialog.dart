import 'package:flutter/material.dart';
import 'package:notes/utilities/dialogs/show_generic_dialog.dart';

Future<void> showCannotShareEmptyNoteDialog(BuildContext context) {
  return showGenericDialog(
    context: context,
    title: "Sharing",
    content: "You cannot share an empty note!",
    optionBuilder: () => {"Ok": null},
  );
}
