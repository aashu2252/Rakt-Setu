// lib/data/repositories/donor_repository_impl.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/entities/donor.dart';
import '../../domain/repositories/donor_repository.dart';
import '../../core/errors/failures.dart';
import '../../core/errors/exceptions.dart';
import '../../core/constants/firebase_constants.dart';
import '../datasources/firestore_datasource.dart';

class DonorRepositoryImpl implements DonorRepository {
  final FirestoreDataSource _dataSource;
  DonorRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, AppUser>> getDonorById(String uid) async {
    try {
      final user = await _dataSource.getUser(uid);
      if (user == null) return const Left(ServerFailure('Donor not found'));
      return Right(user);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> updateAvailability(String uid,
      {required bool isAvailable}) async {
    try {
      await _dataSource.updateUser(
          uid, {FirebaseConstants.fieldIsAvailable: isAvailable});
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> updateDonorLocation(
      String uid, GeoPoint location, String geoHash) async {
    try {
      await _dataSource.updateUser(uid, {
        FirebaseConstants.fieldLocation: location,
        FirebaseConstants.fieldGeoHash: geoHash,
      });
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<Donor>>> getNearbyDonors({
    required GeoPoint center,
    required double radiusKm,
    required String bloodGroup,
  }) async {
    try {
      final stream = _dataSource.getNearbyDonors(
        center: center,
        radiusKm: radiusKm,
        bloodGroup: bloodGroup,
      );
      final users = await stream.first;
      final donors = users
          .map((u) => Donor(
                uid: u.uid,
                name: u.name,
                phone: u.phone,
                bloodGroup: u.bloodGroup ?? '',
                location: u.location,
                lastDonationDate: u.lastDonationDate,
                status: u.isAvailable ? DonorStatus.available : DonorStatus.unavailable,
                fcmToken: u.fcmToken,
                totalDonations: u.totalDonations,
              ))
          .toList();
      return Right(donors);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> updateFcmToken(
      String uid, String token) async {
    try {
      await _dataSource.updateUser(
          uid, {FirebaseConstants.fieldFcmToken: token});
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> recordDonation(
      String uid, DateTime donationDate, String requestId) async {
    try {
      await _dataSource.updateUser(uid, {
        FirebaseConstants.fieldLastDonationDate: donationDate,
        'totalDonations': FieldValue.increment(1),
      });
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
