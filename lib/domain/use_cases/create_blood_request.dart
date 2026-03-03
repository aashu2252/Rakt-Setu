// lib/domain/use_cases/create_blood_request.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import '../entities/blood_request.dart';
import '../repositories/request_repository.dart';
import '../../core/errors/failures.dart';

class CreateBloodRequestParams {
  final String seekerId;
  final String seekerName;
  final String seekerPhone;
  final String bloodGroup;
  final int unitsNeeded;
  final GeoPoint hospitalLocation;
  final String hospitalName;

  const CreateBloodRequestParams({
    required this.seekerId,
    required this.seekerName,
    required this.seekerPhone,
    required this.bloodGroup,
    required this.unitsNeeded,
    required this.hospitalLocation,
    required this.hospitalName,
  });
}

class CreateBloodRequest {
  final RequestRepository _repo;
  CreateBloodRequest(this._repo);

  Future<Either<Failure, BloodRequest>> call(CreateBloodRequestParams p) =>
      _repo.createRequest(
        seekerId: p.seekerId,
        seekerName: p.seekerName,
        seekerPhone: p.seekerPhone,
        bloodGroup: p.bloodGroup,
        unitsNeeded: p.unitsNeeded,
        hospitalLocation: p.hospitalLocation,
        hospitalName: p.hospitalName,
      );
}
