// lib/presentation/screens/seeker/seeker_dashboard.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/blood_request.dart';
import '../../providers/auth_provider.dart';
import '../../providers/request_provider.dart';

class SeekerDashboard extends ConsumerStatefulWidget {
  const SeekerDashboard({super.key});

  @override
  ConsumerState<SeekerDashboard> createState() => _SeekerDashboardState();
}

class _SeekerDashboardState extends ConsumerState<SeekerDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = ref.read(authNotifierProvider).user?.uid;
      if (uid != null) {
        ref.read(requestNotifierProvider.notifier).loadSeekerHistory(uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(requestNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Requests')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppConstants.routeCreateRequest),
        backgroundColor: AppTheme.primaryRed,
        icon: const Icon(Icons.sos_rounded),
        label: const Text('New Request'),
      ),
      body: state.history.isEmpty
          ? const Center(
              child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.bloodtype_outlined,
                    size: 64, color: AppTheme.textSecondary),
                SizedBox(height: 16),
                Text('No requests yet.',
                    style: TextStyle(color: AppTheme.textSecondary)),
              ],
            ))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.history.length,
              itemBuilder: (_, i) =>
                  _SeekerRequestCard(request: state.history[i]),
            ),
    );
  }
}

class _SeekerRequestCard extends StatelessWidget {
  final BloodRequest request;
  const _SeekerRequestCard({required this.request});

  Color get _statusColor {
    switch (request.status) {
      case RequestStatus.pending:
        return AppTheme.warning;
      case RequestStatus.accepted:
      case RequestStatus.donorEnRoute:
        return AppTheme.accentAmber;
      case RequestStatus.completed:
        return AppTheme.success;
      case RequestStatus.cancelled:
      case RequestStatus.expired:
        return AppTheme.textSecondary;
      default:
        return AppTheme.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (request.isActive) {
          context.push(AppConstants.routeTracking, extra: request.id);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryRed.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(request.bloodGroup,
                      style: const TextStyle(
                          color: AppTheme.primaryRed,
                          fontWeight: FontWeight.w800,
                          fontSize: 16)),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(request.status.name,
                      style:
                          TextStyle(color: _statusColor, fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(request.hospitalName,
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              '${request.unitsNeeded} unit(s)  •  ${request.createdAt.day}/${request.createdAt.month}/${request.createdAt.year}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (request.donorName != null) ...[
              const SizedBox(height: 8),
              Row(children: [
                const Icon(Icons.person, size: 14, color: AppTheme.success),
                const SizedBox(width: 4),
                Text('Donor: ${request.donorName}',
                    style: const TextStyle(
                        color: AppTheme.success, fontSize: 13)),
              ]),
            ],
            if (request.isActive) ...[
              const SizedBox(height: 8),
              const Row(children: [
                Icon(Icons.arrow_forward_ios_rounded,
                    size: 12, color: AppTheme.textSecondary),
                SizedBox(width: 4),
                Text('Tap to track',
                    style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12)),
              ]),
            ],
          ],
        ),
      ),
    );
  }
}
