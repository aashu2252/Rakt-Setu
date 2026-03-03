// lib/core/constants/app_constants.dart

class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'RaktSetu';
  static const String appTagline = 'The Hyperlocal Blood Grid';
  static const String appVersion = '1.0.0';

  // Blood Groups
  static const List<String> bloodGroups = [
    'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'
  ];

  // Donation Rules
  static const int minDaysBetweenDonations = 90; // 3 months
  static const int defaultSearchRadiusKm = 5;
  static const int expandedSearchRadiusKm = 10;
  static const int maxSearchRadiusKm = 20;
  static const int minDonorsRequired = 3;

  // Timeouts
  static const int requestExpiryHours = 24;
  static const int donorResponseTimeoutMinutes = 5;

  // Map
  static const double defaultLatitude = 22.7196; // Indore, India
  static const double defaultLongitude = 75.8577;
  static const double defaultZoom = 14.0;

  // Routes
  static const String routeSplash = '/';
  static const String routeLogin = '/login';
  static const String routeOtp = '/otp';
  static const String routeRoleSetup = '/role-setup';
  static const String routeHome = '/home';
  static const String routeDonorDashboard = '/donor-dashboard';
  static const String routeSeekerDashboard = '/seeker-dashboard';
  static const String routeCreateRequest = '/create-request';
  static const String routeTracking = '/tracking';
  static const String routeQrScan = '/qr-scan';
  static const String routeQrDisplay = '/qr-display';

  // Firestore Collections
  static const String colUsers = 'users';
  static const String colRequests = 'blood_requests';
  static const String colNotifications = 'notifications';
  static const String colDonationHistory = 'donation_history';

  // Realtime DB Paths
  static const String rtdbDonorLocations = 'donor_locations';
  static const String rtdbActiveTracking = 'active_tracking';

  // FCM Topics
  static const String fcmTopicEmergency = 'emergency_alerts';
}
