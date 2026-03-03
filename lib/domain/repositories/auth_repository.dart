// lib/domain/repositories/auth_repository.dart
import 'package:dartz/dartz.dart';
import '../entities/app_user.dart';
import '../../core/errors/failures.dart';

abstract class AuthRepository {
  /// Returns current signed-in user or null
  Future<AppUser?> getCurrentUser();

  /// Sends OTP to [phoneNumber]
  Future<Either<AuthFailure, String>> sendOtp(String phoneNumber);

  /// Verifies OTP and returns user
  Future<Either<AuthFailure, AppUser>> verifyOtp(
      String verificationId, String otp);

  /// Updates user role & profile after initial login
  Future<Either<AuthFailure, AppUser>> setupUserProfile({
    required String uid,
    required String name,
    required String role,
    String? bloodGroup,
    DateTime? lastDonationDate,
  });

  /// Signs out the current user
  Future<void> signOut();

  /// Stream of auth state changes
  Stream<AppUser?> get authStateChanges;
}
