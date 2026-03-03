// lib/data/datasources/firestore_datasource.dart
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import '../../core/constants/firebase_constants.dart';
import '../../core/errors/exceptions.dart';
import '../models/user_model.dart';
import '../models/blood_request_model.dart';
import '../../domain/entities/blood_request.dart';

class FirestoreDataSource {
  final FirebaseFirestore _db;

  FirestoreDataSource({required FirebaseFirestore db}) : _db = db;

  // ─── USER / DONOR ────────────────────────────────────────────────────────────

  Future<UserModel?> getUser(String uid) async {
    final doc =
        await _db.collection(FirebaseConstants.usersCollection).doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  Future<void> setUser(UserModel user) async {
    await _db
        .collection(FirebaseConstants.usersCollection)
        .doc(user.uid)
        .set(user.toFirestore(), SetOptions(merge: true));
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _db
        .collection(FirebaseConstants.usersCollection)
        .doc(uid)
        .update(data);
  }

  /// GeoFlutterFire+ query - finds donors within [radiusKm] of [center]
  Stream<List<UserModel>> getNearbyDonors({
    required GeoPoint center,
    required double radiusKm,
    required String bloodGroup,
  }) {
    final collection =
        _db.collection(FirebaseConstants.usersCollection).withConverter<UserModel>(
              fromFirestore: (snap, _) => UserModel.fromFirestore(snap),
              toFirestore: (user, _) => user.toFirestore(),
            );

    return GeoCollectionReference<UserModel>(collection)
        .subscribeWithin(
          center: GeoFirePoint(GeoPoint(center.latitude, center.longitude)),
          radiusInKm: radiusKm,
          field: 'location',
          geopointFrom: (u) => u.location ?? const GeoPoint(0, 0),
          strictMode: true,
        )
        .map((docs) => docs
            .map((d) => d.data()!)
            .where((u) =>
                u.isDonor && u.isAvailable && u.bloodGroup == bloodGroup)
            .toList());
  }

  // ─── BLOOD REQUESTS ──────────────────────────────────────────────────────────

  Future<BloodRequestModel> createRequest(
      BloodRequestModel request) async {
    final ref = await _db
        .collection(FirebaseConstants.requestsCollection)
        .add(request.toFirestore());
    return BloodRequestModel.fromFirestore(await ref.get());
  }

  Future<void> updateRequest(
      String requestId, Map<String, dynamic> data) async {
    await _db
        .collection(FirebaseConstants.requestsCollection)
        .doc(requestId)
        .update(data);
  }

  Stream<BloodRequestModel> watchRequest(String requestId) {
    return _db
        .collection(FirebaseConstants.requestsCollection)
        .doc(requestId)
        .snapshots()
        .map((doc) => BloodRequestModel.fromFirestore(doc));
  }

  Future<List<BloodRequestModel>> getSeekerRequests(String seekerId) async {
    final snap = await _db
        .collection(FirebaseConstants.requestsCollection)
        .where(FirebaseConstants.fieldSeekerId, isEqualTo: seekerId)
        .orderBy(FirebaseConstants.fieldCreatedAt, descending: true)
        .get();
    return snap.docs.map((d) => BloodRequestModel.fromFirestore(d)).toList();
  }

  Future<List<BloodRequestModel>> getDonorRequests(String donorId) async {
    final snap = await _db
        .collection(FirebaseConstants.requestsCollection)
        .where(FirebaseConstants.fieldDonorId, isEqualTo: donorId)
        .orderBy(FirebaseConstants.fieldCreatedAt, descending: true)
        .get();
    return snap.docs.map((d) => BloodRequestModel.fromFirestore(d)).toList();
  }

  Future<void> acceptRequest(
      String requestId, String donorId, String donorName) async {
    await _db.runTransaction((tx) async {
      final ref = _db
          .collection(FirebaseConstants.requestsCollection)
          .doc(requestId);
      final snap = await tx.get(ref);
      final current = BloodRequestModel.fromFirestore(snap);
      if (current.status != RequestStatus.pending) {
        throw const ServerException('Request is no longer available');
      }
      tx.update(ref, {
        FirebaseConstants.fieldDonorId: donorId,
        'donorName': donorName,
        FirebaseConstants.fieldStatus: RequestStatus.accepted.name,
        FirebaseConstants.fieldAcceptedAt: FieldValue.serverTimestamp(),
      });
    });
  }
}
