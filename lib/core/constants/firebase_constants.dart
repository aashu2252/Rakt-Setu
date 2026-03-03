// lib/core/constants/firebase_constants.dart

class FirebaseConstants {
  FirebaseConstants._();

  // Firestore
  static const String usersCollection = 'users';
  static const String requestsCollection = 'blood_requests';
  static const String donationHistoryCollection = 'donation_history';
  static const String notificationsCollection = 'notifications';

  // User Document Fields
  static const String fieldUid = 'uid';
  static const String fieldName = 'name';
  static const String fieldPhone = 'phone';
  static const String fieldBloodGroup = 'bloodGroup';
  static const String fieldRole = 'role'; // 'donor' or 'seeker'
  static const String fieldIsAvailable = 'isAvailable';
  static const String fieldLastDonationDate = 'lastDonationDate';
  static const String fieldFcmToken = 'fcmToken';
  static const String fieldLocation = 'location'; // GeoPoint
  static const String fieldGeoHash = 'geoHash';
  static const String fieldCreatedAt = 'createdAt';

  // Request Document Fields
  static const String fieldSeekerId = 'seekerId';
  static const String fieldDonorId = 'donorId';
  static const String fieldHospitalLocation = 'hospitalLocation';
  static const String fieldHospitalName = 'hospitalName';
  static const String fieldRequestedBloodGroup = 'requestedBloodGroup';
  static const String fieldStatus = 'status';
  static const String fieldUnitsNeeded = 'unitsNeeded';
  static const String fieldExpiresAt = 'expiresAt';
  static const String fieldAcceptedAt = 'acceptedAt';
  static const String fieldCompletedAt = 'completedAt';

  // Realtime Database
  static const String rtdbDonorLocations = 'donor_locations';
  static const String rtdbLatitude = 'latitude';
  static const String rtdbLongitude = 'longitude';
  static const String rtdbTimestamp = 'timestamp';
  static const String rtdbRequestId = 'requestId';
}
