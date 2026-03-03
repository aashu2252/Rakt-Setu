// lib/presentation/screens/tracking/tracking_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/blood_request.dart';
import '../../providers/auth_provider.dart';
import '../../providers/location_provider.dart';
import '../../providers/request_provider.dart';

class TrackingScreen extends ConsumerWidget {
  final String requestId;
  const TrackingScreen({super.key, required this.requestId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestStream = ref.watch(requestNotifierProvider.notifier)
        .watchRequest(requestId);

    return StreamBuilder<BloodRequest>(
      stream: requestStream,
      builder: (context, snap) {
        final req = snap.data;
        return Scaffold(
          appBar: AppBar(
            title: Text(req != null ? req.status.name.toUpperCase() : 'Tracking'),
            actions: [
              if (req?.status == RequestStatus.arrived)
                TextButton(
                  onPressed: () =>
                      context.push(AppConstants.routeQrDisplay, extra: requestId),
                  child: const Text('Show QR',
                      style: TextStyle(color: AppTheme.accentAmber)),
                ),
            ],
          ),
          body: req == null
              ? const Center(child: CircularProgressIndicator())
              : _TrackingBody(request: req),
        );
      },
    );
  }
}

class _TrackingBody extends ConsumerWidget {
  final BloodRequest request;
  const _TrackingBody({required this.request});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authNotifierProvider).user;
    final isDonor = user?.isDonor ?? false;

    // If seeker and donor accepted, watch donor's live location
    final donorLocationAsync = request.donorId != null && !isDonor
        ? ref.watch(donorLiveLocationProvider(request.donorId!))
        : null;

    final donorGeo = donorLocationAsync?.value;

    return Stack(
      children: [
        // Map
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(
              request.hospitalLocation.latitude,
              request.hospitalLocation.longitude,
            ),
            zoom: 14,
          ),
          markers: {
            Marker(
              markerId: const MarkerId('hospital'),
              position: LatLng(
                request.hospitalLocation.latitude,
                request.hospitalLocation.longitude,
              ),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueRed),
              infoWindow: InfoWindow(title: request.hospitalName),
            ),
            if (donorGeo != null)
              Marker(
                markerId: const MarkerId('donor'),
                position:
                    LatLng(donorGeo.latitude, donorGeo.longitude),
                icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueCyan),
                infoWindow: InfoWindow(
                    title: request.donorName ?? 'Donor'),
              ),
          },
        ),
        // Status card at bottom
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: _StatusCard(request: request, isDonor: isDonor, ref: ref),
        ),
      ],
    );
  }
}

class _StatusCard extends StatelessWidget {
  final BloodRequest request;
  final bool isDonor;
  final WidgetRef ref;
  const _StatusCard(
      {required this.request, required this.isDonor, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StatusIndicator(status: request.status),
          const SizedBox(height: 12),
          Text(request.hospitalName,
              style: Theme.of(context).textTheme.titleLarge),
          Text('Blood Group: ${request.bloodGroup}  •  ${request.unitsNeeded} unit(s)',
              style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 20),
          if (isDonor && request.status == RequestStatus.accepted)
            ElevatedButton.icon(
              icon: const Icon(Icons.directions_car_rounded),
              label: const Text('I\'m En Route'),
              onPressed: () => ref
                  .read(requestNotifierProvider.notifier)
                  .updateStatus(request.id, RequestStatus.donorEnRoute),
            ),
          if (isDonor && request.status == RequestStatus.donorEnRoute)
            ElevatedButton.icon(
              icon: const Icon(Icons.location_on_rounded),
              label: const Text('I\'ve Arrived'),
              onPressed: () => ref
                  .read(requestNotifierProvider.notifier)
                  .updateStatus(request.id, RequestStatus.arrived),
            ),
        ],
      ),
    );
  }
}

class _StatusIndicator extends StatelessWidget {
  final RequestStatus status;
  const _StatusIndicator({required this.status});

  Color get color {
    switch (status) {
      case RequestStatus.pending:
        return AppTheme.warning;
      case RequestStatus.accepted:
      case RequestStatus.donorEnRoute:
        return AppTheme.accentAmber;
      case RequestStatus.arrived:
        return AppTheme.primaryRed;
      case RequestStatus.completed:
        return AppTheme.success;
      default:
        return AppTheme.textSecondary;
    }
  }

  String get label {
    switch (status) {
      case RequestStatus.pending:
        return '🔍 Finding Donors...';
      case RequestStatus.accepted:
        return '✅ Donor Accepted';
      case RequestStatus.donorEnRoute:
        return '🚗 Donor En Route';
      case RequestStatus.arrived:
        return '🏥 Donor Arrived';
      case RequestStatus.completed:
        return '🎉 Completed';
      default:
        return status.name;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(label,
          style: TextStyle(color: color, fontWeight: FontWeight.w600)),
    );
  }
}
