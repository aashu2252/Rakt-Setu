// lib/presentation/screens/auth/otp_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';

class OtpScreen extends ConsumerStatefulWidget {
  final String phone;
  const OtpScreen({super.key, required this.phone});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final _otpCtrl = TextEditingController();

  Future<void> _verify() async {
    if (_otpCtrl.text.length != 6) return;
    await ref.read(authNotifierProvider.notifier).verifyOtp(_otpCtrl.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authNotifierProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Verify OTP')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text('Enter the 6-digit OTP\nsent to ${widget.phone}',
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 40),
            TextField(
              controller: _otpCtrl,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .displayMedium
                  ?.copyWith(letterSpacing: 16),
              decoration: const InputDecoration(
                  labelText: 'OTP', counterText: ''),
            ),
            if (auth.error != null) ...[
              const SizedBox(height: 12),
              Text(auth.error!,
                  style: const TextStyle(color: AppTheme.lightRed)),
            ],
            const Spacer(),
            ElevatedButton(
              onPressed: auth.isLoading ? null : _verify,
              child: auth.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Text('Verify & Continue'),
            ),
          ],
        ),
      ),
    );
  }
}
