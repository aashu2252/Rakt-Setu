// lib/domain/use_cases/accept_request.dart
import 'package:dartz/dartz.dart';
import '../repositories/request_repository.dart';
import '../../core/errors/failures.dart';

class AcceptRequest {
  final RequestRepository _repo;
  AcceptRequest(this._repo);

  Future<Either<Failure, void>> call({
    required String requestId,
    required String donorId,
    required String donorName,
  }) =>
      _repo.acceptRequest(requestId, donorId, donorName);
}
