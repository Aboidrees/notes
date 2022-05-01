import 'package:flutter/material.dart';
import 'package:notes/constants/routes.dart';
import 'package:notes/enums/menu_actions.dart';
import 'package:notes/services/auth/auth_service.dart';
import 'package:notes/services/curd/notes_service.dart';
import 'package:notes/utilities/dialogs/logout_dialog.dart';
import 'package:notes/views/notes/notes_list_view.dart';

class NotesView extends StatefulWidget {
  const NotesView({Key? key}) : super(key: key);

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  late final NoteService _noteService;
  String get userEmail => AuthService.firebase().currentUser!.email;

  @override
  void initState() {
    _noteService = NoteService();
    _noteService.open();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notes"),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).pushNamed(createOrUpdateNoteRoute),
            icon: const Icon(Icons.add),
          ),
          PopupMenuButton<MenuActions>(
            onSelected: (value) async {
              switch (value) {
                case MenuActions.logout:
                  final shouldLogout = await showLogOutDialog(context);
                  if (shouldLogout) {
                    AuthService.firebase().logOut();
                    Navigator.of(context).pushNamedAndRemoveUntil(loginRoute, (_) => false);
                  }
                  break;
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: MenuActions.logout,
                child: Text("Logout"),
              ),
            ],
          )
        ],
      ),
      body: FutureBuilder(
        future: _noteService.getOrCreateUser(email: userEmail),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              return StreamBuilder(
                stream: _noteService.allNotes,
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                    case ConnectionState.active:
                      if (snapshot.hasData) {
                        final allNotes = snapshot.data as List<DatabaseNote>;
                        return NotesListView(
                          notes: allNotes,
                          onDeleteNote: (note) async => await _noteService.deleteNote(id: note.id),
                          onTap: (note) => Navigator.of(context).pushNamed(createOrUpdateNoteRoute, arguments: note),
                        );
                      } else {
                        return const Center(child: CircularProgressIndicator());
                      }
                    default:
                      return const Center(child: CircularProgressIndicator());
                  }
                },
              );
            default:
              return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
