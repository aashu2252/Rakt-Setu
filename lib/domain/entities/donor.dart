// lib/domain/entities/donor.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum DonorStatus { available, unavailable, donating }

class Donor extends Equatable {
  final String uid;
  final String name;
  final String phone;
  final String bloodGroup;
  final GeoPoint? location;
  final DonorStatus status;
  final DateTime? lastDonationDate;
  final String? fcmToken;
  final int totalDonations;
  final double rating;

  const Donor({
    required this.uid,
    required this.name,
    required this.phone,
    required this.bloodGroup,
    this.location,
    this.status = DonorStatus.available,
    this.lastDonationDate,
    this.fcmToken,
    this.totalDonations = 0,
    this.rating = 5.0,
  });

  bool get isEligible {
    if (status != DonorStatus.available) return false;
    if (lastDonationDate == null) return true;
    return DateTime.now().difference(lastDonationDate!).inDays >= 90;
  }

  @override
  List<Object?> get props => [uid, bloodGroup, status, lastDonationDate];
}
