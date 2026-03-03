// lib/data/models/blood_request_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/blood_request.dart';
import '../../core/constants/firebase_constants.dart';

class BloodRequestModel extends BloodRequest {
  const BloodRequestModel({
    required super.id,
    required super.seekerId,
    required super.seekerName,
    required super.seekerPhone,
    required super.bloodGroup,
    required super.unitsNeeded,
    required super.hospitalLocation,
    required super.hospitalName,
    super.status,
    super.donorId,
    super.donorName,
    required super.createdAt,
    required super.expiresAt,
    super.acceptedAt,
    super.completedAt,
  });

  factory BloodRequestModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BloodRequestModel(
      id: doc.id,
      seekerId: data[FirebaseConstants.fieldSeekerId] ?? '',
      seekerName: data['seekerName'] ?? '',
      seekerPhone: data['seekerPhone'] ?? '',
      bloodGroup: data[FirebaseConstants.fieldRequestedBloodGroup] ?? '',
      unitsNeeded: data[FirebaseConstants.fieldUnitsNeeded] ?? 1,
      hospitalLocation:
          data[FirebaseConstants.fieldHospitalLocation] as GeoPoint,
      hospitalName: data[FirebaseConstants.fieldHospitalName] ?? '',
      status: _parseStatus(data[FirebaseConstants.fieldStatus]),
      donorId: data[FirebaseConstants.fieldDonorId],
      donorName: data['donorName'],
      createdAt:
          (data[FirebaseConstants.fieldCreatedAt] as Timestamp).toDate(),
      expiresAt:
          (data[FirebaseConstants.fieldExpiresAt] as Timestamp).toDate(),
      acceptedAt: data[FirebaseConstants.fieldAcceptedAt] != null
          ? (data[FirebaseConstants.fieldAcceptedAt] as Timestamp).toDate()
          : null,
      completedAt: data[FirebaseConstants.fieldCompletedAt] != null
          ? (data[FirebaseConstants.fieldCompletedAt] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() => {
        FirebaseConstants.fieldSeekerId: seekerId,
        'seekerName': seekerName,
        'seekerPhone': seekerPhone,
        FirebaseConstants.fieldRequestedBloodGroup: bloodGroup,
        FirebaseConstants.fieldUnitsNeeded: unitsNeeded,
        FirebaseConstants.fieldHospitalLocation: hospitalLocation,
        FirebaseConstants.fieldHospitalName: hospitalName,
        FirebaseConstants.fieldStatus: status.name,
        FirebaseConstants.fieldDonorId: donorId,
        'donorName': donorName,
        FirebaseConstants.fieldCreatedAt: Timestamp.fromDate(createdAt),
        FirebaseConstants.fieldExpiresAt: Timestamp.fromDate(expiresAt),
      };

  static RequestStatus _parseStatus(String? s) {
    return RequestStatus.values.firstWhere(
      (e) => e.name == s,
      orElse: () => RequestStatus.pending,
    );
  }
}
