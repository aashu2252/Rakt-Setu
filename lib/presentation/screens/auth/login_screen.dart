// lib/presentation/screens/auth/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';

import '../../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneCtrl = TextEditingController();

  @override
  void dispose() {
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;
    final phone = '+91${_phoneCtrl.text.trim()}';
    await ref.read(authNotifierProvider.notifier).sendOtp(phone);
    if (!mounted) return;
    final error = ref.read(authNotifierProvider).error;
    if (error == null) {
      context.push(AppConstants.routeOtp, extra: phone);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authNotifierProvider);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(),
                // Logo
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryRed,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.bloodtype_rounded,
                      size: 40, color: Colors.white),
                ),
                const SizedBox(height: 24),
                Text('Welcome to\nRaktSetu',
                    style: Theme.of(context).textTheme.displayLarge),
                const SizedBox(height: 8),
                Text('Enter your phone number to continue',
                    style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 40),
                // Phone field
                TextFormField(
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  style: const TextStyle(color: AppTheme.textPrimary),
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    prefixText: '+91  ',
                    prefixStyle: TextStyle(color: AppTheme.textPrimary),
                    counterText: '',
                  ),
                  validator: (v) {
                    if (v == null || v.length != 10) {
                      return 'Enter valid 10-digit number';
                    }
                    return null;
                  },
                ),
                if (auth.error != null) ...[
                  const SizedBox(height: 12),
                  Text(auth.error!,
                      style: const TextStyle(color: AppTheme.lightRed)),
                ],
                const Spacer(),
                ElevatedButton(
                  onPressed: auth.isLoading ? null : _sendOtp,
                  child: auth.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Text('Send OTP'),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
