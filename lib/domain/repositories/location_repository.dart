// lib/domain/repositories/location_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/errors/failures.dart';

abstract class LocationRepository {
  /// Returns the current device position
  Future<Either<LocationFailure, Position>> getCurrentPosition();

  /// Starts streaming the donor's live location to Realtime DB
  Future<Either<LocationFailure, void>> startLiveTracking(
      String donorId, String requestId);

  /// Stops the live location stream from Realtime DB
  Future<Either<LocationFailure, void>> stopLiveTracking(String donorId);

  /// Streams the live location of a donor (for the seeker's map)
  Stream<GeoPoint?> watchDonorLocation(String donorId);

  /// One-time location permission check/request
  Future<bool> requestLocationPermission();
}
