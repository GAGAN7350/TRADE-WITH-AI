import 'package:cloud_firestore/cloud_firestore.dart';

/// Service class for handling Firestore database operations
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get a reference to a collection
  CollectionReference collection(String path) {
    return _firestore.collection(path);
  }

  /// Get a document by ID
  Future<DocumentSnapshot> getDocument(String collection, String docId) async {
    return await _firestore.collection(collection).doc(docId).get();
  }

  /// Create or update a document
  Future<void> setDocument({
    required String collection,
    required String docId,
    required Map<String, dynamic> data,
    bool merge = true,
  }) async {
    await _firestore.collection(collection).doc(docId).set(data, SetOptions(merge: merge));
  }

  /// Update a document
  Future<void> updateDocument({
    required String collection,
    required String docId,
    required Map<String, dynamic> data,
  }) async {
    await _firestore.collection(collection).doc(docId).update(data);
  }

  /// Delete a document
  Future<void> deleteDocument(String collection, String docId) async {
    await _firestore.collection(collection).doc(docId).delete();
  }

  /// Get a stream of a document
  Stream<DocumentSnapshot> documentStream(String collection, String docId) {
    return _firestore.collection(collection).doc(docId).snapshots();
  }

  /// Get a stream of a collection
  Stream<QuerySnapshot> collectionStream(
    String collection, {
    Query Function(Query)? queryBuilder,
  }) {
    Query query = _firestore.collection(collection);
    if (queryBuilder != null) {
      query = queryBuilder(query);
    }
    return query.snapshots();
  }

  /// Batch write operations
  Future<void> batchWrite(List<Map<String, dynamic>> operations) async {
    final batch = _firestore.batch();

    for (final operation in operations) {
      final collection = operation['collection'] as String;
      final docId = operation['docId'] as String;
      final data = operation['data'] as Map<String, dynamic>;
      final type = operation['type'] as String; // 'set', 'update', 'delete'

      final docRef = _firestore.collection(collection).doc(docId);

      switch (type) {
        case 'set':
          batch.set(docRef, data);
          break;
        case 'update':
          batch.update(docRef, data);
          break;
        case 'delete':
          batch.delete(docRef);
          break;
      }
    }

    await batch.commit();
  }
}
