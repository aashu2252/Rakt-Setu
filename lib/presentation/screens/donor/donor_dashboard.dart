// lib/presentation/screens/donor/donor_dashboard.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/blood_request.dart';
import '../../providers/auth_provider.dart';
import '../../providers/request_provider.dart';

class DonorDashboard extends ConsumerStatefulWidget {
  const DonorDashboard({super.key});

  @override
  ConsumerState<DonorDashboard> createState() => _DonorDashboardState();
}

class _DonorDashboardState extends ConsumerState<DonorDashboard> {
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
    final user = ref.watch(authNotifierProvider).user;
    final requests = ref.watch(requestNotifierProvider).history;

    return Scaffold(
      appBar: AppBar(title: const Text('Donor Dashboard')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Donor Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.deepRed, AppTheme.primaryRed],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.white24,
                    child: Text(
                      user?.bloodGroup ?? '?',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 20),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user?.name ?? '',
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 18)),
                      Text('${user?.totalDonations ?? 0} lives saved',
                          style: const TextStyle(color: Colors.white70)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Eligibility status
            _EligibilityBanner(lastDonation: user?.lastDonationDate),
            const SizedBox(height: 24),
            Text('Recent Activity',
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 12),
            if (requests.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: Text('No donations yet.\nAccept a request to get started!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppTheme.textSecondary)),
                ),
              )
            else
              ...requests.map((r) => _RequestTile(request: r)),
          ],
        ),
      ),
    );
  }
}

class _EligibilityBanner extends StatelessWidget {
  final DateTime? lastDonation;
  const _EligibilityBanner({this.lastDonation});

  @override
  Widget build(BuildContext context) {
    final daysSince = lastDonation != null
        ? DateTime.now().difference(lastDonation!).inDays
        : 999;
    final eligible = daysSince >= 90;
    final daysLeft = (90 - daysSince).clamp(0, 90);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: eligible
            ? AppTheme.success.withValues(alpha: 0.1)
            : AppTheme.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: eligible ? AppTheme.success : AppTheme.warning),
      ),
      child: Row(
        children: [
          Icon(eligible ? Icons.check_circle : Icons.timer,
              color: eligible ? AppTheme.success : AppTheme.warning),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              eligible
                  ? '✅ You are eligible to donate!'
                  : '⏳ Eligible to donate in $daysLeft days',
              style: TextStyle(
                  color: eligible ? AppTheme.success : AppTheme.warning,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _RequestTile extends StatelessWidget {
  final BloodRequest request;
  const _RequestTile({required this.request});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primaryRed.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(request.bloodGroup,
                style: const TextStyle(
                    color: AppTheme.primaryRed,
                    fontWeight: FontWeight.w800)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(request.hospitalName,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(request.status.name,
                    style: const TextStyle(
                        color: AppTheme.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          Icon(
            request.status == RequestStatus.completed
                ? Icons.check_circle
                : Icons.circle_outlined,
            color: request.status == RequestStatus.completed
                ? AppTheme.success
                : AppTheme.textSecondary,
          ),
        ],
      ),
    );
  }
}
