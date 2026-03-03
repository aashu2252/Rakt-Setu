// lib/presentation/router/app_router.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';

import '../providers/auth_provider.dart';
import '../screens/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/otp_screen.dart';
import '../screens/auth/role_setup_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/donor/donor_dashboard.dart';
import '../screens/seeker/seeker_dashboard.dart';
import '../screens/request/request_screen.dart';
import '../screens/tracking/tracking_screen.dart';
import '../screens/qr/qr_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authNotifierProvider);

  return GoRouter(
    initialLocation: AppConstants.routeSplash,
    redirect: (context, state) {
      final path = state.matchedLocation;
      if (authState.isLoading) return null;

      if (!authState.isAuthenticated) {
        if (path == AppConstants.routeLogin ||
            path == AppConstants.routeOtp) {
          return null;
        }
        return AppConstants.routeLogin;
      }

      if (authState.needsRoleSetup) {
        if (path == AppConstants.routeRoleSetup) return null;
        return AppConstants.routeRoleSetup;
      }

      if (path == AppConstants.routeSplash ||
          path == AppConstants.routeLogin ||
          path == AppConstants.routeOtp ||
          path == AppConstants.routeRoleSetup) {
        return AppConstants.routeHome;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppConstants.routeSplash,
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: AppConstants.routeLogin,
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: AppConstants.routeOtp,
        builder: (_, state) =>
            OtpScreen(phone: state.extra as String? ?? ''),
      ),
      GoRoute(
        path: AppConstants.routeRoleSetup,
        builder: (_, __) => const RoleSetupScreen(),
      ),
      GoRoute(
        path: AppConstants.routeHome,
        builder: (_, __) => const HomeScreen(),
      ),
      GoRoute(
        path: AppConstants.routeDonorDashboard,
        builder: (_, __) => const DonorDashboard(),
      ),
      GoRoute(
        path: AppConstants.routeSeekerDashboard,
        builder: (_, __) => const SeekerDashboard(),
      ),
      GoRoute(
        path: AppConstants.routeCreateRequest,
        builder: (_, __) => const RequestScreen(),
      ),
      GoRoute(
        path: AppConstants.routeTracking,
        builder: (_, state) =>
            TrackingScreen(requestId: state.extra as String? ?? ''),
      ),
      GoRoute(
        path: AppConstants.routeQrDisplay,
        builder: (_, state) =>
            QrScreen(requestId: state.extra as String? ?? ''),
      ),
    ],
    errorBuilder: (_, state) => Scaffold(
      body: Center(child: Text('Page not found: ${state.error}')),
    ),
  );
});
