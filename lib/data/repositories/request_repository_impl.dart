// lib/data/repositories/request_repository_impl.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import '../../domain/entities/blood_request.dart';
import '../../domain/repositories/request_repository.dart';
import '../../core/errors/failures.dart';
import '../../core/errors/exceptions.dart';
import '../datasources/firestore_datasource.dart';
import '../models/blood_request_model.dart';

class RequestRepositoryImpl implements RequestRepository {
  final FirestoreDataSource _dataSource;
  RequestRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, BloodRequest>> createRequest({
    required String seekerId,
    required String seekerName,
    required String seekerPhone,
    required String bloodGroup,
    required int unitsNeeded,
    required GeoPoint hospitalLocation,
    required String hospitalName,
  }) async {
    try {
      final model = BloodRequestModel(
        id: '',
        seekerId: seekerId,
        seekerName: seekerName,
        seekerPhone: seekerPhone,
        bloodGroup: bloodGroup,
        unitsNeeded: unitsNeeded,
        hospitalLocation: hospitalLocation,
        hospitalName: hospitalName,
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(hours: 24)),
      );
      final created = await _dataSource.createRequest(model);
      return Right(created);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> acceptRequest(
      String requestId, String donorId, String donorName) async {
    try {
      await _dataSource.acceptRequest(requestId, donorId, donorName);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> updateRequestStatus(
      String requestId, RequestStatus status) async {
    try {
      await _dataSource.updateRequest(requestId, {'status': status.name});
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> completeRequest(String requestId) async {
    try {
      await _dataSource.updateRequest(requestId, {
        'status': RequestStatus.completed.name,
        'completedAt': FieldValue.serverTimestamp(),
      });
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Stream<BloodRequest> watchRequest(String requestId) =>
      _dataSource.watchRequest(requestId);

  @override
  Future<Either<Failure, List<BloodRequest>>> getSeekerRequests(
      String seekerId) async {
    try {
      final list = await _dataSource.getSeekerRequests(seekerId);
      return Right(list);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<BloodRequest>>> getDonorRequests(
      String donorId) async {
    try {
      final list = await _dataSource.getDonorRequests(donorId);
      return Right(list);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
