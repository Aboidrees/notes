// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:notes/extensions/list/filter.dart';
// import 'package:notes/services/curd/crud_exceptions.dart';
// import 'package:sqflite/sqflite.dart';
// import 'package:path_provider/path_provider.dart';
// import "package:path/path.dart" show join;

// class NoteService {
//   Database? _db;

//   List<DatabaseNote> _notes = [];
//   DatabaseUser? _user;

//   NoteService._sharedInstance() {
//     _noteStreamController = StreamController<List<DatabaseNote>>.broadcast(
//       onListen: () => _noteStreamController.sink.add(_notes),
//     );
//   }

//   static final NoteService _shared = NoteService._sharedInstance();
//   factory NoteService() => _shared;

//   late final StreamController<List<DatabaseNote>> _noteStreamController;

//   Stream<List<DatabaseNote>> get allNotes => _noteStreamController.stream.filter(
//         (note) {
//           final currentUser = _user;
//           if (currentUser != null) {
//             return note.userId == currentUser.id;
//           } else {
//             throw UserShouldBeSetBeforeReadingAllNotes();
//           }
//         },
//       );

//   Future<DatabaseUser> getOrCreateUser({required String email, bool setAsCurrentUser = true}) async {
//     try {
//       final user = await getUser(email: email);
//       if (setAsCurrentUser) _user = user;
//       return user;
//     } on CouldNoteFindUser {
//       final createdUser = await createUser(email: email);
//       if (setAsCurrentUser) _user = createdUser;
//       return createdUser;
//     } catch (e) {
//       rethrow;
//     }
//   }

//   Future<void> _cacheNotes() async {
//     final allNotes = await getAllNotes();
//     _notes = allNotes.toList();
//     _noteStreamController.add(_notes);
//   }

//   Future<DatabaseNote> updateNote({required DatabaseNote note, required String text}) async {
//     await _ensureDBIsOpen();
//     final db = _getDatabaseOrThrow();
//     await getNote(id: note.id);

//     final updateCount = await db.update(
//       noteTable,
//       {
//         textColumn: text,
//         isSyncedColumn: 0,
//       },
//       where: "id=?",
//       whereArgs: [note.id],
//     );

//     if (updateCount == 0) throw CouldNoteUpdateNote();

//     final updatedNote = await getNote(id: note.id);

//     _notes.removeWhere((note) => note.id == updatedNote.id);
//     _notes.add(updatedNote);
//     _noteStreamController.add(_notes);

//     return updatedNote;
//   }

//   Future<Iterable<DatabaseNote>> getAllNotes() async {
//     await _ensureDBIsOpen();
//     final db = _getDatabaseOrThrow();

//     final notes = await db.query(noteTable);
//     return notes.map((noteRow) => DatabaseNote.fromRow(noteRow));
//   }

//   Future<DatabaseNote> getNote({required int id}) async {
//     await _ensureDBIsOpen();
//     final db = _getDatabaseOrThrow();

//     final notes = await db.query(
//       noteTable,
//       limit: 1,
//       where: "id=?",
//       whereArgs: [id],
//     );

//     if (notes.isEmpty) throw CouldNoteFindNote();

//     final note = DatabaseNote.fromRow(notes.first);
//     _notes.removeWhere((note) => note.id == id);
//     _notes.add(note);
//     _noteStreamController.add(_notes);
//     return note;
//   }

//   Future<int> deleteAllNotes() async {
//     await _ensureDBIsOpen();
//     final db = _getDatabaseOrThrow();
//     final numberOfDeletion = await db.delete(noteTable);
//     _notes = [];
//     _noteStreamController.add(_notes);
//     return numberOfDeletion;
//   }

//   Future<void> deleteNote({required int id}) async {
//     await _ensureDBIsOpen();
//     final db = _getDatabaseOrThrow();
//     final deletedCount = await db.delete(
//       noteTable,
//       where: 'id=?',
//       whereArgs: [id],
//     );
//     if (deletedCount == 0) throw CouldNoteDeleteNote();

//     _notes.removeWhere((note) => note.id == id);
//     _noteStreamController.add(_notes);
//   }

//   Future<DatabaseNote> createNote({required DatabaseUser owner}) async {
//     await _ensureDBIsOpen();
//     final db = _getDatabaseOrThrow();

//     // make sure owner exists in the database with the correct id
//     final dbUser = await getUser(email: owner.email);

//     if (dbUser != owner) throw CouldNoteFindUser();

//     const text = '';

//     //create the note
//     final noteId = await db.insert(noteTable, {
//       userIdColumn: owner.id,
//       textColumn: text,
//       isSyncedColumn: 1,
//     });

//     final note = DatabaseNote(
//       id: noteId,
//       userId: owner.id,
//       text: text,
//       isSyncedWithCloud: true,
//     );
//     _notes.add(note);
//     _noteStreamController.add(_notes);

//     return note;
//   }

//   Future<void> deleteUser({required String email}) async {
//     await _ensureDBIsOpen();
//     final db = _getDatabaseOrThrow();
//     final deletedCount = await db.delete(
//       userTable,
//       where: 'email=?',
//       whereArgs: [email.toLowerCase()],
//     );
//     if (deletedCount != 1) throw CouldNotDeleteUserException();
//   }

//   Future<DatabaseUser> createUser({required String email}) async {
//     await _ensureDBIsOpen();
//     final db = _getDatabaseOrThrow();
//     final result = await db.query(
//       userTable,
//       where: "email=?",
//       whereArgs: [email.toLowerCase()],
//     );

//     if (result.isNotEmpty) throw UserAlreadyExistsException();

//     final userId = await db.insert(userTable, {emailColumn: email.toLowerCase()});
//     return DatabaseUser(id: userId, email: email);
//   }

//   Future<DatabaseUser> getUser({required String email}) async {
//     await _ensureDBIsOpen();
//     final db = _getDatabaseOrThrow();
//     final result = await db.query(
//       userTable,
//       limit: 1,
//       where: "email=?",
//       whereArgs: [email.toLowerCase()],
//     );

//     if (result.isEmpty) throw CouldNoteFindUser();
//     return DatabaseUser.fromRow(result.first);
//   }

//   Database _getDatabaseOrThrow() {
//     final db = _db;
//     if (db == null) throw DatabaseIsNotOpenException();
//     return db;
//   }

//   Future<void> open() async {
//     if (_db != null) throw DatabaseAlreadyOpenException();

//     try {
//       final docPath = await getApplicationDocumentsDirectory();
//       final dbPath = join(docPath.path, dbName);
//       final db = await openDatabase(dbPath);
//       _db = db;
//       // create the user table
//       await db.execute(createUserTable);
//       // create the note table
//       await db.execute(createNoteTable);

//       await _cacheNotes();
//     } on MissingPlatformDirectoryException {
//       throw UnableToGetDocumentException();
//     }
//   }

//   Future<void> _ensureDBIsOpen() async {
//     try {
//       await open();
//     } on DatabaseAlreadyOpenException {
//       // empty
//     }
//   }

//   Future<void> close() async {
//     final db = _db;
//     if (db == null) throw DatabaseIsNotOpenException();
//     await db.close();
//     _db = null;
//   }
// }

// @immutable
// class DatabaseUser {
//   final int id;
//   final String email;
//   const DatabaseUser({
//     required this.id,
//     required this.email,
//   });

//   DatabaseUser.fromRow(Map<String, Object?> map)
//       : id = map[idColumn] as int,
//         email = map[emailColumn] as String;

//   @override
//   String toString() => 'person, ID = $id, email = $email';

//   @override
//   bool operator ==(covariant DatabaseUser other) => id == other.id;

//   @override
//   int get hashCode => id.hashCode;
// }

// @immutable
// class DatabaseNote {
//   final int id;
//   final int userId;
//   final String text;
//   final bool isSyncedWithCloud;

//   const DatabaseNote({
//     required this.id,
//     required this.userId,
//     required this.text,
//     required this.isSyncedWithCloud,
//   });

//   DatabaseNote.fromRow(Map<String, Object?> map)
//       : id = map[idColumn] as int,
//         userId = map[userIdColumn] as int,
//         text = map[textColumn] as String,
//         isSyncedWithCloud = (map[isSyncedColumn] as int) == 1;

//   @override
//   String toString() => "Note, ID = $id, userId = $userId, isSyncedWithCloud=$isSyncedWithCloud, text=$text";

//   @override
//   bool operator ==(covariant DatabaseNote other) => id == other.id;

//   @override
//   int get hashCode => id.hashCode;
// }

// const dbName = 'notes.db';
// const noteTable = 'notes';
// const userTable = 'user';
// const idColumn = 'id';
// const emailColumn = 'email';
// const userIdColumn = 'user_id';
// const textColumn = 'text';
// const isSyncedColumn = 'is_synced_with_cloud';

// const createUserTable = '''
//         CREATE TABLE IF NOT EXISTS "user" (
//           "id" INTEGER NOT NULL,
//           "email" TEXT NOT NULL,
//           PRIMARY KEY ("id" AUTOINCREMENT)
//         );
//       ''';
// const createNoteTable = '''
//         CREATE TABLE IF NOT EXISTS "notes" (
//           "id" INTEGER NOT NULL,
//           "user_id" INTEGER NOT NULL,
//           "text" TEXT,
//           "is_synced_with_cloud" INTEGER NOT NULL DEFAULT 0,
//           FOREIGN KEY ("user_id") REFERENCES "user" ("id"),
//           PRIMARY KEY("id" AUTOINCREMENT)
//         );
//       ''';
