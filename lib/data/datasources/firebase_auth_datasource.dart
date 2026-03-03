import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import '../../core/errors/exceptions.dart';
import '../../core/constants/firebase_constants.dart';
import '../models/user_model.dart';

class FirebaseAuthDataSource {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  FirebaseAuthDataSource({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
  })  : _auth = auth,
        _firestore = firestore;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<String> sendOtp(String phoneNumber) async {
    final completer = Completer<String>();

    if (kIsWeb) {
      final verifier = RecaptchaVerifier(
        auth: FirebaseAuthPlatform.instance,
        container: 'recaptcha-container',
        size: RecaptchaVerifierSize.compact,
        theme: RecaptchaVerifierTheme.light,
      );
      final confirmationResult = await _auth.signInWithPhoneNumber(
        phoneNumber,
        verifier,
      );
      // confirmationResult.verificationId is what we need to verify the OTP later
      completer.complete(confirmationResult.verificationId);
    } else {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          throw AuthException(e.message ?? 'OTP send failed');
        },
        codeSent: (String id, int? resendToken) {
          completer.complete(id);
        },
        codeAutoRetrievalTimeout: (String id) {
          if (!completer.isCompleted) completer.complete(id);
        },
        timeout: const Duration(seconds: 60),
      );
    }
    
    return completer.future;
  }

  Future<UserCredential> verifyOtp(
      String verificationId, String smsCode) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'OTP verification failed');
    }
  }

  Future<UserModel?> getUserFromFirestore(String uid) async {
    final doc = await _firestore
        .collection(FirebaseConstants.usersCollection)
        .doc(uid)
        .get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  Future<UserModel> createUserInFirestore(UserModel user) async {
    await _firestore
        .collection(FirebaseConstants.usersCollection)
        .doc(user.uid)
        .set(user.toFirestore());
    return user;
  }

  Future<void> updateUserInFirestore(
      String uid, Map<String, dynamic> data) async {
    await _firestore
        .collection(FirebaseConstants.usersCollection)
        .doc(uid)
        .update(data);
  }

  Future<void> signOut() => _auth.signOut();

  String? get currentUid => _auth.currentUser?.uid;
}
