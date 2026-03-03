// lib/presentation/providers/auth_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../data/datasources/firebase_auth_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';

// ─── Infrastructure Providers ────────────────────────────────────────────────

final firebaseAuthProvider =
    Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);

final firestoreProvider =
    Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);

// ─── DataSource Providers ─────────────────────────────────────────────────────

final authDataSourceProvider = Provider<FirebaseAuthDataSource>((ref) {
  return FirebaseAuthDataSource(
    auth: ref.watch(firebaseAuthProvider),
    firestore: ref.watch(firestoreProvider),
  );
});

// ─── Repository Provider ──────────────────────────────────────────────────────

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.watch(authDataSourceProvider));
});

// ─── State Notifier ───────────────────────────────────────────────────────────

class AuthState {
  final AppUser? user;
  final bool isLoading;
  final String? error;
  final String? verificationId;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.verificationId,
  });

  bool get isAuthenticated => user != null;
  bool get needsRoleSetup =>
      user != null && user!.role == UserRole.unassigned;

  AuthState copyWith({
    AppUser? user,
    bool? isLoading,
    String? error,
    String? verificationId,
  }) =>
      AuthState(
        user: user ?? this.user,
        isLoading: isLoading ?? this.isLoading,
        error: error,
        verificationId: verificationId ?? this.verificationId,
      );
}

class AuthNotifier extends Notifier<AuthState> {
  AuthRepository get _repo => ref.read(authRepositoryProvider);

  @override
  AuthState build() {
    _init();
    return const AuthState();
  }

  void _init() {
    _repo.authStateChanges.listen((user) {
      state = state.copyWith(user: user, isLoading: false);
    });
  }

  Future<void> sendOtp(String phone) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _repo.sendOtp(phone);
    result.fold(
      (fail) => state = state.copyWith(isLoading: false, error: fail.message),
      (vid) => state = state.copyWith(isLoading: false, verificationId: vid),
    );
  }

  Future<void> verifyOtp(String otp) async {
    state = state.copyWith(isLoading: true, error: null);
    final result =
        await _repo.verifyOtp(state.verificationId!, otp);
    result.fold(
      (fail) => state = state.copyWith(isLoading: false, error: fail.message),
      (user) => state = state.copyWith(isLoading: false, user: user),
    );
  }

  Future<void> setupProfile({
    required String name,
    required String role,
    String? bloodGroup,
    DateTime? lastDonationDate,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _repo.setupUserProfile(
      uid: state.user!.uid,
      name: name,
      role: role,
      bloodGroup: bloodGroup,
      lastDonationDate: lastDonationDate,
    );
    result.fold(
      (fail) => state = state.copyWith(isLoading: false, error: fail.message),
      (user) => state = state.copyWith(isLoading: false, user: user),
    );
  }

  Future<void> signOut() async {
    await _repo.signOut();
    state = const AuthState();
  }
}

final authNotifierProvider =
    NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
