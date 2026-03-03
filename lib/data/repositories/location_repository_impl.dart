// lib/data/repositories/location_repository_impl.dart
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:geolocator/geolocator.dart';
import '../../domain/repositories/location_repository.dart';
import '../../core/errors/failures.dart';

import '../datasources/realtime_db_datasource.dart';

class LocationRepositoryImpl implements LocationRepository {
  final RealtimeDbDataSource _rtdb;
  LocationRepositoryImpl(this._rtdb);

  @override
  Future<bool> requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  @override
  Future<Either<LocationFailure, Position>> getCurrentPosition() async {
    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      return Right(pos);
    } catch (e) {
      return Left(LocationFailure(e.toString()));
    }
  }

  @override
  Future<Either<LocationFailure, void>> startLiveTracking(
      String donorId, String requestId) async {
    try {
      final stream = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10, // update every 10 meters
        ),
      ).map((pos) => (lat: pos.latitude, lng: pos.longitude));

      _rtdb.startDonorLocationStream(
        donorId: donorId,
        requestId: requestId,
        locationStream: stream,
      );
      return const Right(null);
    } catch (e) {
      return Left(LocationFailure(e.toString()));
    }
  }

  @override
  Future<Either<LocationFailure, void>> stopLiveTracking(
      String donorId) async {
    try {
      await _rtdb.stopDonorLocationStream(donorId);
      return const Right(null);
    } catch (e) {
      return Left(LocationFailure(e.toString()));
    }
  }

  @override
  Stream<GeoPoint?> watchDonorLocation(String donorId) =>
      _rtdb.watchDonorLocation(donorId);
}
