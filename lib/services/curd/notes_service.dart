import 'package:flutter/material.dart';
import 'package:notes/services/curd/crud_exceptions.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import "package:path/path.dart" show join;

class NoateService {
  Database? _db;

  Future<void> deteteUser({required String email}) async {
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(
      userTable,
      where: 'email=?',
      whereArgs: [email.toLowerCase()],
    );
    if (deletedCount != 1) throw CouldNotDeleteUserException();
  }

  Future<DatabaseUser> createUser({required String email}) async {
    final db = _getDatabaseOrThrow();
    final result = await db.query(
      userTable,
      where: "email=?",
      whereArgs: [email.toLowerCase()],
    );

    if (result.isNotEmpty) throw UserAlreadyExistsException();

    final userId = await db.insert(userTable, {emailColumn: email.toLowerCase()});
    return DatabaseUser(id: userId, email: email);
  }

  Future<DatabaseUser> getUser({required String email}) async {
    final db = _getDatabaseOrThrow();
    final result = await db.query(
      userTable,
      limit: 1,
      where: "email=?",
      whereArgs: [email.toLowerCase()],
    );

    if (result.isEmpty) throw CouldNoteFindUser();
    return DatabaseUser.fromRow(result.first);
  }

  Future<DatabaseNote> createNote({required DatabaseUser owner}) async {
    final db = _getDatabaseOrThrow();

    // make sure owner exists in the database with the correct id
    final dbUser = await getUser(email: owner.email);

    if (dbUser != owner) throw CouldNoteFindUser();

    const text = '';

    //create the note
    final noteId = await db.insert(noteTable, {
      userIdColumn: owner.id,
      textColumn: text,
      isSyncedColumn: 1,
    });

    final note = DatabaseNote(
      id: noteId,
      userId: owner.id,
      text: text,
      isSyncedWithCloud: true,
    );

    return note;
  }

  Future<void> deleteNote({required int id}) async {
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(
      noteTable,
      where: 'id=?',
      whereArgs: [id],
    );
    if (deletedCount == 0) throw CouldNoteDeleteNote();
  }

  Future<int> deleteAllNotes() async {
    final db = _getDatabaseOrThrow();
    return await db.delete(noteTable);
  }

  Future<DatabaseNote> getNote({required int id}) async {
    final db = _getDatabaseOrThrow();

    final note = await db.query(
      noteTable,
      limit: 1,
      where: "id=?",
      whereArgs: [id],
    );

    if (note.isEmpty) throw CouldNoteFindNote();

    return DatabaseNote.fromRow(note.first);
  }

  Future<Iterable<DatabaseNote>> getAllNotes() async {
    final db = _getDatabaseOrThrow();

    final notes = await db.query(noteTable);
    return notes.map((noteRow) => DatabaseNote.fromRow(noteRow));
  }

  Future<DatabaseNote> updateNote({
    required DatabaseNote note,
    required String text,
  }) async {
    final db = _getDatabaseOrThrow();
    await getNote(id: note.id);

    final updateCount = await db.update(noteTable, {
      textColumn: text,
      isSyncedColumn: 0,
    });

    if (updateCount == 0) throw CouldNoteUpdateNote();

    return await getNote(id: note.id);
  }

  Database _getDatabaseOrThrow() {
    final db = _db;
    if (db == null) throw DatabaseIsNotOpenException();
    return db;
  }

  Future<void> open() async {
    if (_db != null) throw DatabaseAlreadyOpenException();

    try {
      final docPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docPath.path, dbName);
      final db = await openDatabase(dbPath);
      _db = db;
      // create the user table
      await db.execute(createUserTable);
      // create the note table
      await db.execute(createNoteTable);
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentException();
    }
  }

  Future<void> close() async {
    final db = _db;
    if (db == null) throw DatabaseIsNotOpenException();
    await db.close();
    _db = null;
  }
}

@immutable
class DatabaseUser {
  final int id;
  final String email;
  const DatabaseUser({
    required this.id,
    required this.email,
  });

  DatabaseUser.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        email = map[emailColumn] as String;

  @override
  String toString() => 'person, ID = $id, emai = $email';

  @override
  bool operator ==(covariant DatabaseUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

@immutable
class DatabaseNote {
  final int id;
  final int userId;
  final String text;
  final bool isSyncedWithCloud;

  const DatabaseNote({
    required this.id,
    required this.userId,
    required this.text,
    required this.isSyncedWithCloud,
  });

  DatabaseNote.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        userId = map[userIdColumn] as int,
        text = map[textColumn] as String,
        isSyncedWithCloud = (map[isSyncedColumn] as int) == 1;

  @override
  String toString() => "Note, ID = $id, userId = $userId, isSyncedWithCloud=$isSyncedWithCloud, text=$text";

  @override
  bool operator ==(covariant DatabaseNote other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

const dbName = 'notes.db';
const noteTable = 'notes';
const userTable = 'user';
const idColumn = 'id';
const emailColumn = 'email';
const userIdColumn = 'user_id';
const textColumn = 'text';
const isSyncedColumn = 'is_synced_with_cloud';

const createUserTable = '''
        CREATE TABLE IF NOT EXISTS "user" (
          "id" INTEGER NOT NULL,
          "email" TEXT NOT NULL,
          PRIMARY KEY ("id" AUTOENCREMENT)
        );
      ''';
const createNoteTable = '''
        CREATE TABLE IF NOT EXISTS "note" (
          "id" INTEGER NOT NULL,
          "user_id" INTEGER NOT NULL,
          "text" TEXT,
          "is_synced_with_cloud" INTEGER NOT NULL DEFAULT 0,
          FORRIGN KEY ("user_id") REFERENCES "user" ("id"),
          PRIMARY KEY("id" AUTOINCREMENT)
        );
      ''';
