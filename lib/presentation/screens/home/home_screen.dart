// lib/presentation/screens/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/app_user.dart';
import '../../providers/auth_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authNotifierProvider);
    final user = auth.user;
    if (user == null) return const SizedBox.shrink();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            const Text('RaktSetu'),
            Text(
              user.isDonor ? '🩸 Life Saver Mode' : '🏥 Help Seeker Mode',
              style: const TextStyle(
                  fontSize: 11, color: AppTheme.textSecondary),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () =>
                ref.read(authNotifierProvider.notifier).signOut(),
          ),
        ],
      ),
      body: user.isDonor
          ? _DonorHomeBody(user: user)
          : _SeekerHomeBody(user: user),
    );
  }
}

// ─── Donor Home ───────────────────────────────────────────────────────────────

class _DonorHomeBody extends ConsumerWidget {
  final AppUser user;
  const _DonorHomeBody({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _WelcomeBanner(name: user.name, isDonor: true),
          const SizedBox(height: 24),
          _StatRow(user: user),
          const SizedBox(height: 24),
          _QuickActionCard(
            title: 'My Dashboard',
            subtitle: 'View requests, history & stats',
            icon: Icons.dashboard_rounded,
            onTap: () => context.push(AppConstants.routeDonorDashboard),
          ),
        ],
      ),
    );
  }
}

// ─── Seeker Home ──────────────────────────────────────────────────────────────

class _SeekerHomeBody extends ConsumerWidget {
  final AppUser user;
  const _SeekerHomeBody({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _WelcomeBanner(name: user.name, isDonor: false),
          const SizedBox(height: 32),
          // SOS Button
          GestureDetector(
            onTap: () => context.push(AppConstants.routeCreateRequest),
            child: Container(
              width: double.infinity,
              height: 180,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.deepRed, AppTheme.primaryRed],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryRed.withValues(alpha: 0.4),
                    blurRadius: 32,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.sos_rounded, size: 64, color: Colors.white),
                  const SizedBox(height: 12),
                  Text('REQUEST BLOOD',
                      style: Theme.of(context)
                          .textTheme
                          .headlineLarge
                          ?.copyWith(color: Colors.white)),
                  const SizedBox(height: 4),
                  const Text('Tap in an emergency',
                      style: TextStyle(color: Colors.white70)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          _QuickActionCard(
            title: 'My Requests',
            subtitle: 'View your active & past requests',
            icon: Icons.history_rounded,
            onTap: () => context.push(AppConstants.routeSeekerDashboard),
          ),
        ],
      ),
    );
  }
}

// ─── Shared Widgets ───────────────────────────────────────────────────────────

class _WelcomeBanner extends StatelessWidget {
  final String name;
  final bool isDonor;
  const _WelcomeBanner({required this.name, required this.isDonor});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: AppTheme.primaryRed.withValues(alpha: 0.15),
          child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: const TextStyle(
                  color: AppTheme.primaryRed,
                  fontSize: 22,
                  fontWeight: FontWeight.w700)),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hello, ${name.split(' ').first}! 👋',
                style: Theme.of(context).textTheme.headlineMedium),
            Text(isDonor ? 'Ready to save a life?' : 'Find help near you',
                style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  final AppUser user;
  const _StatRow({required this.user});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatCard(label: 'Blood Group', value: user.bloodGroup ?? '--'),
        const SizedBox(width: 12),
        _StatCard(label: 'Donations', value: '${user.totalDonations}'),
        const SizedBox(width: 12),
        _StatCard(
            label: 'Status',
            value: user.isAvailable ? 'Active' : 'Off',
            valueColor: user.isAvailable ? AppTheme.success : AppTheme.textSecondary),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  const _StatCard(
      {required this.label,
      required this.value,
      this.valueColor = AppTheme.textPrimary});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppTheme.cardDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.divider),
        ),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: valueColor)),
            const SizedBox(height: 4),
            Text(label,
                style: const TextStyle(
                    fontSize: 11, color: AppTheme.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.cardDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.divider),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryRed.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppTheme.primaryRed),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: Theme.of(context).textTheme.titleLarge),
                  Text(subtitle,
                      style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 16, color: AppTheme.textSecondary),
          ],
        ),
      ),
    );
  }
}
