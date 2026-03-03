// lib/domain/use_cases/get_nearby_donors.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import '../entities/donor.dart';
import '../repositories/donor_repository.dart';
import '../../core/errors/failures.dart';
import '../../core/constants/app_constants.dart';

class GetNearbyDonors {
  final DonorRepository _repo;
  GetNearbyDonors(this._repo);

  /// DRE Algorithm: recursive radius expansion
  Future<Either<Failure, List<Donor>>> call({
    required GeoPoint center,
    required String bloodGroup,
  }) async {
    for (final radius in [
      AppConstants.defaultSearchRadiusKm.toDouble(),
      AppConstants.expandedSearchRadiusKm.toDouble(),
      AppConstants.maxSearchRadiusKm.toDouble(),
    ]) {
      final result = await _repo.getNearbyDonors(
        center: center,
        radiusKm: radius,
        bloodGroup: bloodGroup,
      );

      if (result.isRight()) {
        final donors = result.getOrElse(() => []);
        final eligible = donors.where((d) => d.isEligible).toList();
        if (eligible.length >= AppConstants.minDonorsRequired) {
          return Right(eligible);
        }
      }
    }
    return const Left(NoDonorsFoundFailure());
  }
}
