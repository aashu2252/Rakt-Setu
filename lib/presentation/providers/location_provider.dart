// lib/presentation/providers/location_provider.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/location_repository.dart';
import '../../data/datasources/realtime_db_datasource.dart';
import '../../data/repositories/location_repository_impl.dart';

final firebaseDatabaseProvider =
    Provider<FirebaseDatabase>((ref) => FirebaseDatabase.instance);

final rtdbDataSourceProvider = Provider<RealtimeDbDataSource>((ref) {
  return RealtimeDbDataSource(rtdb: ref.watch(firebaseDatabaseProvider));
});

final locationRepositoryProvider = Provider<LocationRepository>((ref) {
  return LocationRepositoryImpl(ref.watch(rtdbDataSourceProvider));
});

// Current donor live position stream (for seeker map)
final donorLiveLocationProvider =
    StreamProvider.family<GeoPoint?, String>((ref, donorId) {
  return ref.watch(locationRepositoryProvider).watchDonorLocation(donorId);
});
