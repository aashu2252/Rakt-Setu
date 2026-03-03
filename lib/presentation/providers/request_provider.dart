// lib/presentation/providers/request_provider.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/blood_request.dart';
import '../../domain/repositories/request_repository.dart';
import '../../data/datasources/firestore_datasource.dart';
import '../../data/repositories/request_repository_impl.dart';
import 'auth_provider.dart';

// ─── DataSource / Repo Providers ──────────────────────────────────────────────

final firestoreDataSourceProvider = Provider<FirestoreDataSource>((ref) {
  return FirestoreDataSource(db: ref.watch(firestoreProvider));
});

final requestRepositoryProvider = Provider<RequestRepository>((ref) {
  return RequestRepositoryImpl(ref.watch(firestoreDataSourceProvider));
});

// ─── State ────────────────────────────────────────────────────────────────────

class RequestState {
  final BloodRequest? activeRequest;
  final List<BloodRequest> history;
  final bool isLoading;
  final String? error;

  const RequestState({
    this.activeRequest,
    this.history = const [],
    this.isLoading = false,
    this.error,
  });

  RequestState copyWith({
    BloodRequest? activeRequest,
    List<BloodRequest>? history,
    bool? isLoading,
    String? error,
  }) =>
      RequestState(
        activeRequest: activeRequest ?? this.activeRequest,
        history: history ?? this.history,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}

class RequestNotifier extends Notifier<RequestState> {
  RequestRepository get _repo => ref.read(requestRepositoryProvider);

  @override
  RequestState build() {
    return const RequestState();
  }

  Future<void> createRequest({
    required String seekerId,
    required String seekerName,
    required String seekerPhone,
    required String bloodGroup,
    required int unitsNeeded,
    required GeoPoint hospitalLocation,
    required String hospitalName,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _repo.createRequest(
      seekerId: seekerId,
      seekerName: seekerName,
      seekerPhone: seekerPhone,
      bloodGroup: bloodGroup,
      unitsNeeded: unitsNeeded,
      hospitalLocation: hospitalLocation,
      hospitalName: hospitalName,
    );
    result.fold(
      (fail) => state = state.copyWith(isLoading: false, error: fail.message),
      (req) => state =
          state.copyWith(isLoading: false, activeRequest: req),
    );
  }

  Future<void> acceptRequest(
      String requestId, String donorId, String donorName) async {
    state = state.copyWith(isLoading: true);
    final result = await _repo.acceptRequest(requestId, donorId, donorName);
    result.fold(
      (fail) => state = state.copyWith(isLoading: false, error: fail.message),
      (_) => state = state.copyWith(isLoading: false),
    );
  }

  Future<void> updateStatus(String requestId, RequestStatus status) async {
    await _repo.updateRequestStatus(requestId, status);
  }

  Future<void> completeRequest(String requestId) async {
    await _repo.completeRequest(requestId);
    state = state.copyWith(activeRequest: null);
  }

  Stream<BloodRequest> watchRequest(String requestId) =>
      _repo.watchRequest(requestId);

  Future<void> loadSeekerHistory(String seekerId) async {
    final result = await _repo.getSeekerRequests(seekerId);
    result.fold(
      (_) {},
      (list) => state = state.copyWith(history: list),
    );
  }
}

final requestNotifierProvider =
    NotifierProvider<RequestNotifier, RequestState>(RequestNotifier.new);
