import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RemoteDataSource {
  final FirebaseFirestore _firestore;

  RemoteDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  DocumentReference _userDoc(String uid) =>
      _firestore.collection('users').doc(uid);

  CollectionReference<Map<String, dynamic>> _trips(String uid) =>
      _userDoc(uid).collection('trips');

  CollectionReference<Map<String, dynamic>> _subCol(
          String uid, String tripId, String collection) =>
      _trips(uid).doc(tripId).collection(collection);

  CollectionReference<Map<String, dynamic>> _settings(String uid) =>
      _userDoc(uid).collection('settings');

  Future<void> _ensureUserDocument(String uid) async {
    final ref = _userDoc(uid);
    final snapshot = await ref.get();
    final now = FieldValue.serverTimestamp();
    final user = FirebaseAuth.instance.currentUser;

    if (snapshot.exists) {
      await ref.set({'updatedAt': now}, SetOptions(merge: true));
      return;
    }

    await ref.set({
      'name': user?.displayName ??
          user?.email?.split('@').first ??
          'User',
      if (user?.email != null) 'email': user!.email,
      'createdAt': now,
      'updatedAt': now,
    }, SetOptions(merge: true));
  }

  Future<void> createTrip(String uid, Map<String, dynamic> data) async {
    await _ensureUserDocument(uid);
    await _trips(uid).doc(data['id'] as String).set(data);
  }

  Future<void> updateTrip(
      String uid, String tripId, Map<String, dynamic> data) async {
    await _ensureUserDocument(uid);
    await _trips(uid).doc(tripId).update(data);
  }

  Future<void> deleteTrip(String uid, String tripId) async {
    await _trips(uid).doc(tripId).delete();
  }

  Future<Map<String, dynamic>?> getTrip(String uid, String tripId) async {
    final doc = await _trips(uid).doc(tripId).get();
    return doc.exists ? doc.data() : null;
  }

  Future<List<Map<String, dynamic>>> getAllTrips(String uid) async {
    final snapshot = await _trips(uid).get();
    return snapshot.docs.map((d) => d.data()).toList();
  }

  Future<void> createSubEntity(String uid, String tripId,
      String collection, Map<String, dynamic> data) async {
    await _ensureUserDocument(uid);
    await _subCol(uid, tripId, collection).doc(data['id'] as String).set(data);
  }

  Future<void> updateSubEntity(String uid, String tripId,
      String collection, String id, Map<String, dynamic> data) async {
    await _ensureUserDocument(uid);
    await _subCol(uid, tripId, collection).doc(id).update(data);
  }

  Future<void> deleteSubEntity(
      String uid, String tripId, String collection, String id) async {
    await _subCol(uid, tripId, collection).doc(id).delete();
  }

  Future<List<Map<String, dynamic>>> getAllSubEntities(
      String uid, String tripId, String collection) async {
    final snapshot = await _subCol(uid, tripId, collection).get();
    return snapshot.docs.map((d) => d.data()).toList();
  }

  Future<void> saveSettings(String uid, Map<String, dynamic> data) async {
    await _ensureUserDocument(uid);
    await _settings(uid).doc('app').set(data);
  }

  Future<Map<String, dynamic>?> getSettings(String uid) async {
    final doc = await _settings(uid).doc('app').get();
    return doc.exists ? doc.data() : null;
  }
}
