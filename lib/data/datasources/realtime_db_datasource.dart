// lib/data/datasources/realtime_db_datasource.dart
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../core/constants/firebase_constants.dart';


class RealtimeDbDataSource {
  final FirebaseDatabase _rtdb;
  StreamSubscription? _locationSub;

  RealtimeDbDataSource({required FirebaseDatabase rtdb}) : _rtdb = rtdb;

  /// Starts streaming the device's location to RTDB at 2-second intervals
  void startDonorLocationStream({
    required String donorId,
    required String requestId,
    required Stream<({double lat, double lng})> locationStream,
  }) {
    _locationSub = locationStream.listen((pos) {
      _rtdb
          .ref('${FirebaseConstants.rtdbDonorLocations}/$donorId')
          .set({
        FirebaseConstants.rtdbLatitude: pos.lat,
        FirebaseConstants.rtdbLongitude: pos.lng,
        FirebaseConstants.rtdbTimestamp:
            ServerValue.timestamp,
        FirebaseConstants.rtdbRequestId: requestId,
      });
    });
  }

  /// Stops streaming and removes the RTDB entry
  Future<void> stopDonorLocationStream(String donorId) async {
    await _locationSub?.cancel();
    _locationSub = null;
    await _rtdb
        .ref('${FirebaseConstants.rtdbDonorLocations}/$donorId')
        .remove();
  }

  /// Returns a live stream of a donor's position for the seeker's map
  Stream<GeoPoint?> watchDonorLocation(String donorId) {
    return _rtdb
        .ref('${FirebaseConstants.rtdbDonorLocations}/$donorId')
        .onValue
        .map((event) {
      final data = event.snapshot.value as Map?;
      if (data == null) return null;
      return GeoPoint(
        (data[FirebaseConstants.rtdbLatitude] as num).toDouble(),
        (data[FirebaseConstants.rtdbLongitude] as num).toDouble(),
      );
    });
  }
}
