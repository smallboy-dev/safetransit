import 'dart:async';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  // Authentication
  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> createUserWithEmailAndPassword(String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> signInAnonymously() async {
    return await _auth.signInAnonymously();
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // Firestore Operations
  Future<void> setDocument(String collection, String docId, Map<String, dynamic> data, {bool merge = false}) async {
    await _firestore.collection(collection).doc(docId).set(data, SetOptions(merge: merge));
  }

  Future<DocumentSnapshot> getDocument(String collection, String docId) async {
    return await _firestore.collection(collection).doc(docId).get();
  }

  Future<QuerySnapshot> getCollection(String collection, {Query? query}) async {
    if (query != null) {
      return await query.get();
    }
    return await _firestore.collection(collection).get();
  }

  Stream<DocumentSnapshot> documentStream(String collection, String docId) {
    return _firestore.collection(collection).doc(docId).snapshots();
  }

  Stream<QuerySnapshot> collectionStream(String collection, {Query? query}) {
    if (query != null) {
      return query.snapshots();
    }
    return _firestore.collection(collection).snapshots();
  }

  Future<void> updateDocument(String collection, String docId, Map<String, dynamic> data) async {
    await _firestore.collection(collection).doc(docId).update(data);
  }

  Future<void> deleteDocument(String collection, String docId) async {
    await _firestore.collection(collection).doc(docId).delete();
  }

  // Storage Operations
  Future<String> uploadFile(String filePath, String fileName) async {
    Reference ref = _storage.ref().child(filePath).child(fileName);
    UploadTask uploadTask = ref.putFile(File(fileName));
    TaskSnapshot snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  // Messaging
  Future<String?> getFCMToken() async {
    return await _messaging.getToken();
  }

  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
  }

  // User Management
  Future<void> createUserData(String userId, Map<String, dynamic> userData) async {
    await setDocument('users', userId, userData);
  }

  Future<DocumentSnapshot> getUserData(String userId) async {
    return await getDocument('users', userId);
  }

  Future<void> updateUserData(String userId, Map<String, dynamic> userData) async {
    await updateDocument('users', userId, userData);
  }

  // Vehicle Management
  Future<void> createVehicle(String vehicleId, Map<String, dynamic> vehicleData) async {
    await setDocument('vehicles', vehicleId, vehicleData);
  }

  Future<QuerySnapshot> getAvailableVehicles() async {
    return await getCollection('vehicles', query: _firestore.collection('vehicles').where('status', isEqualTo: 'available'));
  }

  // Trip Management
  Future<void> createTrip(String tripId, Map<String, dynamic> tripData) async {
    await setDocument('trips', tripId, tripData);
  }

  Future<void> updateTripStatus(String tripId, String status) async {
    await updateDocument('trips', tripId, {'status': status, 'updatedAt': Timestamp.now()});
  }

  Stream<QuerySnapshot> getActiveTrips() {
    return collectionStream('trips', query: _firestore.collection('trips').where('status', whereIn: ['active', 'pending']));
  }

  // Location Tracking
  Future<void> updateLocation(String userId, Map<String, dynamic> locationData) async {
    await updateDocument('users', userId, {
      'location': locationData,
      'lastLocationUpdate': Timestamp.now(),
    });
  }

  Stream<DocumentSnapshot> getLocationStream(String userId) {
    return documentStream('users', userId);
  }

  // Driver Reachability Status
  Stream<DocumentSnapshot> getDriverStatusStream(String driverId) {
    return documentStream('drivers', driverId);
  }
}

