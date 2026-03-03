// lib/data/models/user_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/app_user.dart';
import '../../core/constants/firebase_constants.dart';

class UserModel extends AppUser {
  const UserModel({
    required super.uid,
    required super.name,
    required super.phone,
    super.role,
    super.bloodGroup,
    super.photoUrl,
    super.location,
    super.lastDonationDate,
    super.isAvailable,
    super.fcmToken,
    super.totalDonations,
    required super.createdAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      name: data[FirebaseConstants.fieldName] ?? '',
      phone: data[FirebaseConstants.fieldPhone] ?? '',
      role: _parseRole(data[FirebaseConstants.fieldRole]),
      bloodGroup: data[FirebaseConstants.fieldBloodGroup],
      location: data[FirebaseConstants.fieldLocation] as GeoPoint?,
      isAvailable: data[FirebaseConstants.fieldIsAvailable] ?? true,
      fcmToken: data[FirebaseConstants.fieldFcmToken],
      totalDonations: data['totalDonations'] ?? 0,
      lastDonationDate: data[FirebaseConstants.fieldLastDonationDate] != null
          ? (data[FirebaseConstants.fieldLastDonationDate] as Timestamp).toDate()
          : null,
      createdAt: data[FirebaseConstants.fieldCreatedAt] != null
          ? (data[FirebaseConstants.fieldCreatedAt] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        FirebaseConstants.fieldUid: uid,
        FirebaseConstants.fieldName: name,
        FirebaseConstants.fieldPhone: phone,
        FirebaseConstants.fieldRole: role.name,
        FirebaseConstants.fieldBloodGroup: bloodGroup,
        FirebaseConstants.fieldIsAvailable: isAvailable,
        FirebaseConstants.fieldFcmToken: fcmToken,
        'totalDonations': totalDonations,
        FirebaseConstants.fieldLastDonationDate: lastDonationDate != null
            ? Timestamp.fromDate(lastDonationDate!)
            : null,
        FirebaseConstants.fieldCreatedAt: Timestamp.fromDate(createdAt),
      };

  static UserRole _parseRole(String? r) {
    switch (r) {
      case 'donor':
        return UserRole.donor;
      case 'seeker':
        return UserRole.seeker;
      default:
        return UserRole.unassigned;
    }
  }

  UserModel copyWith({
    String? name,
    UserRole? role,
    String? bloodGroup,
    bool? isAvailable,
    String? fcmToken,
    GeoPoint? location,
    DateTime? lastDonationDate,
    int? totalDonations,
  }) =>
      UserModel(
        uid: uid,
        name: name ?? this.name,
        phone: phone,
        role: role ?? this.role,
        bloodGroup: bloodGroup ?? this.bloodGroup,
        location: location ?? this.location,
        isAvailable: isAvailable ?? this.isAvailable,
        fcmToken: fcmToken ?? this.fcmToken,
        totalDonations: totalDonations ?? this.totalDonations,
        lastDonationDate: lastDonationDate ?? this.lastDonationDate,
        createdAt: createdAt,
      );
}
