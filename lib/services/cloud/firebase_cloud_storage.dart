import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:notes/services/cloud/cloud_note.dart';
import 'package:notes/services/cloud/cloud_storage_constants.dart';
import 'package:notes/services/cloud/cloud_storage_exceptions.dart';

class FirebaseCloudStorage {
  final notesCollRef = FirebaseFirestore.instance.collection("notes");

  Future<void> deleteNote({required String documentId}) async {
    try {
      await notesCollRef.doc(documentId).delete();
    } catch (e) {
      throw CouldNotDeleteNoteException();
    }
  }

  Future<void> updateNote({required String documentId, required String text}) async {
    try {
      await notesCollRef.doc(documentId).update({kTextFieldName: text});
    } catch (e) {
      throw CouldNotUpdateNoteException();
    }
  }

  Stream<Iterable<CloudNote>> allNotes({required String ownerUserId}) {
    return notesCollRef.snapshots().map(
      (snapshot) {
        return snapshot.docs
            .map(
              (doc) => CloudNote.fromSnapshot(doc),
            )
            .where(
              (note) => note.ownerUserId == ownerUserId,
            );
      },
    );
  }

  Future<Iterable<CloudNote>> getNote({required String ownerUserId}) async {
    try {
      // using collection reference
      // to set the condition and getting the documents
      // from the collection using the reference
      // this will return a snapshot query
      final snapshot = await notesCollRef.where(kOwnerUserIdFieldName, isEqualTo: ownerUserId).get();
      // List of the document that returned from the query snapshot
      final List<QueryDocumentSnapshot<Map<String, dynamic>>> documents = snapshot.docs;
      // mapping all the documents to CloudNote objects
      final cloudNotes = documents.map((doc) => CloudNote.fromSnapshot(doc));
      return cloudNotes;
    } catch (e) {
      throw CouldNotGetAllNotesException();
    }
  }

  void createNewNote({required String ownerUserId}) async {
    await notesCollRef.add({kOwnerUserIdFieldName: ownerUserId, kTextFieldName: ''});
  }

  factory FirebaseCloudStorage() => _shared;
  FirebaseCloudStorage._sharedInstance();
  static final FirebaseCloudStorage _shared = FirebaseCloudStorage._sharedInstance();
}
