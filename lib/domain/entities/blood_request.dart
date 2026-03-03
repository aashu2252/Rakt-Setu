// lib/domain/entities/blood_request.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum RequestStatus {
  pending,
  accepted,
  donorEnRoute,
  arrived,
  completed,
  cancelled,
  expired,
}

class BloodRequest extends Equatable {
  final String id;
  final String seekerId;
  final String seekerName;
  final String seekerPhone;
  final String bloodGroup;
  final int unitsNeeded;
  final GeoPoint hospitalLocation;
  final String hospitalName;
  final RequestStatus status;
  final String? donorId;
  final String? donorName;
  final DateTime createdAt;
  final DateTime expiresAt;
  final DateTime? acceptedAt;
  final DateTime? completedAt;

  const BloodRequest({
    required this.id,
    required this.seekerId,
    required this.seekerName,
    required this.seekerPhone,
    required this.bloodGroup,
    required this.unitsNeeded,
    required this.hospitalLocation,
    required this.hospitalName,
    this.status = RequestStatus.pending,
    this.donorId,
    this.donorName,
    required this.createdAt,
    required this.expiresAt,
    this.acceptedAt,
    this.completedAt,
  });

  bool get isActive =>
      status == RequestStatus.pending ||
      status == RequestStatus.accepted ||
      status == RequestStatus.donorEnRoute;

  @override
  List<Object?> get props => [id, status, donorId];
}
