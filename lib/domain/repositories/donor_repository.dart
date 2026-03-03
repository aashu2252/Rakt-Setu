// lib/domain/repositories/donor_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import '../entities/app_user.dart';
import '../entities/donor.dart';
import '../../core/errors/failures.dart';

abstract class DonorRepository {
  /// Fetches donor profile by UID
  Future<Either<Failure, AppUser>> getDonorById(String uid);

  /// Updates donor availability status
  Future<Either<Failure, void>> updateAvailability(String uid,
      {required bool isAvailable});

  /// Updates donor GPS location in Firestore (geo-indexed)
  Future<Either<Failure, void>> updateDonorLocation(
      String uid, GeoPoint location, String geoHash);

  /// Queries donors within radius matching blood group
  Future<Either<Failure, List<Donor>>> getNearbyDonors({
    required GeoPoint center,
    required double radiusKm,
    required String bloodGroup,
  });

  /// Updates FCM token for push notifications
  Future<Either<Failure, void>> updateFcmToken(String uid, String token);

  /// Records a completed donation
  Future<Either<Failure, void>> recordDonation(
      String uid, DateTime donationDate, String requestId);
}
