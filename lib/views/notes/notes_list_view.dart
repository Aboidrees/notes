import 'package:flutter/material.dart';
import 'package:notes/services/curd/notes_service.dart';
import 'package:notes/utilities/dialogs/show_delete_dialog.dart';

typedef NoteCallback = void Function(DatabaseNote note);

class NotesListView extends StatelessWidget {
  final List<DatabaseNote> notes;
  final NoteCallback onDeleteNote;
  final NoteCallback onTap;

  const NotesListView({
    Key? key,
    required this.notes,
    required this.onDeleteNote,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: notes.length,
      itemBuilder: (BuildContext context, int index) {
        final note = notes[index];

        return ListTile(
          title: Text(note.text, maxLines: 1, softWrap: true, overflow: TextOverflow.ellipsis),
          trailing: IconButton(
            onPressed: () async {
              final shouldDelete = await showDeleteDialog(context);
              if (shouldDelete) onDeleteNote(note);
            },
            icon: const Icon(Icons.delete),
          ),
          onTap: () => onTap(note),
        );
      },
    );
  }
}
