// lib/domain/use_cases/verify_donor_eligibility.dart
import '../entities/donor.dart';
import '../repositories/donor_repository.dart';

class VerifyDonorEligibility {
  // ignore: unused_field
  final DonorRepository _repo;
  VerifyDonorEligibility(this._repo);

  bool call(Donor donor) => donor.isEligible;
}
