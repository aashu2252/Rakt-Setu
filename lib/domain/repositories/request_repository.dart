// lib/domain/repositories/request_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import '../entities/blood_request.dart';
import '../../core/errors/failures.dart';

abstract class RequestRepository {
  /// Creates a new blood request in Firestore (triggers Cloud Function)
  Future<Either<Failure, BloodRequest>> createRequest({
    required String seekerId,
    required String seekerName,
    required String seekerPhone,
    required String bloodGroup,
    required int unitsNeeded,
    required GeoPoint hospitalLocation,
    required String hospitalName,
  });

  /// Donor accepts an active request
  Future<Either<Failure, void>> acceptRequest(
      String requestId, String donorId, String donorName);

  /// Updates the request status (e.g. donorEnRoute → arrived → completed)
  Future<Either<Failure, void>> updateRequestStatus(
      String requestId, RequestStatus status);

  /// Completes request via QR code scan
  Future<Either<Failure, void>> completeRequest(String requestId);

  /// Real-time stream of a specific request
  Stream<BloodRequest> watchRequest(String requestId);

  /// Seeker's active requests
  Future<Either<Failure, List<BloodRequest>>> getSeekerRequests(String seekerId);

  /// Donor's assigned requests
  Future<Either<Failure, List<BloodRequest>>> getDonorRequests(String donorId);
}
