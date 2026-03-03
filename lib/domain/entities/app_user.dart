// lib/domain/entities/app_user.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum UserRole { donor, seeker, unassigned }

class AppUser extends Equatable {
  final String uid;
  final String name;
  final String phone;
  final UserRole role;
  final String? bloodGroup;
  final String? photoUrl;
  final GeoPoint? location;
  final DateTime? lastDonationDate;
  final bool isAvailable;
  final String? fcmToken;
  final int totalDonations;
  final DateTime createdAt;

  const AppUser({
    required this.uid,
    required this.name,
    required this.phone,
    this.role = UserRole.unassigned,
    this.bloodGroup,
    this.photoUrl,
    this.location,
    this.lastDonationDate,
    this.isAvailable = true,
    this.fcmToken,
    this.totalDonations = 0,
    required this.createdAt,
  });

  bool get isDonor => role == UserRole.donor;
  bool get isSeeker => role == UserRole.seeker;

  @override
  List<Object?> get props => [uid, role, isAvailable];
}
