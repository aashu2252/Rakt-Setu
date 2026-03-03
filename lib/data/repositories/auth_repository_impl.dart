// lib/data/repositories/auth_repository_impl.dart
import 'dart:async';
import 'package:dartz/dartz.dart';

import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../core/errors/failures.dart';
import '../../core/errors/exceptions.dart';
import '../../core/constants/firebase_constants.dart';
import '../datasources/firebase_auth_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthDataSource _dataSource;
  AuthRepositoryImpl(this._dataSource);

  @override
  Future<AppUser?> getCurrentUser() async {
    final uid = _dataSource.currentUid;
    if (uid == null) return null;
    return _dataSource.getUserFromFirestore(uid);
  }

  @override
  Future<Either<AuthFailure, String>> sendOtp(String phoneNumber) async {
    try {
      final verificationId = await _dataSource.sendOtp(phoneNumber);
      return Right(verificationId);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    }
  }

  @override
  Future<Either<AuthFailure, AppUser>> verifyOtp(
      String verificationId, String otp) async {
    try {
      final cred = await _dataSource.verifyOtp(verificationId, otp);
      final uid = cred.user!.uid;
      var user = await _dataSource.getUserFromFirestore(uid);
      if (user == null) {
        // New user — create skeleton profile
        user = UserModel(
          uid: uid,
          name: cred.user!.displayName ?? '',
          phone: cred.user!.phoneNumber ?? '',
          createdAt: DateTime.now(),
        );
        await _dataSource.createUserInFirestore(user);
      }
      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    }
  }

  @override
  Future<Either<AuthFailure, AppUser>> setupUserProfile({
    required String uid,
    required String name,
    required String role,
    String? bloodGroup,
    DateTime? lastDonationDate,
  }) async {
    try {
      await _dataSource.updateUserInFirestore(uid, {
        FirebaseConstants.fieldName: name,
        FirebaseConstants.fieldRole: role,
        if (bloodGroup != null) FirebaseConstants.fieldBloodGroup: bloodGroup,
        if (lastDonationDate != null)
          FirebaseConstants.fieldLastDonationDate: lastDonationDate,
      });
      final user = await _dataSource.getUserFromFirestore(uid);
      return Right(user!);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    }
  }

  @override
  Future<void> signOut() => _dataSource.signOut();

  @override
  Stream<AppUser?> get authStateChanges => _dataSource.authStateChanges.asyncMap(
        (user) async {
          if (user == null) return null;
          return _dataSource.getUserFromFirestore(user.uid);
        },
      );
}
