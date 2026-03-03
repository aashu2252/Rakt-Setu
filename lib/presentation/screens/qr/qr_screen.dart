// lib/presentation/screens/qr/qr_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/request_provider.dart';

class QrScreen extends ConsumerWidget {
  final String requestId;
  const QrScreen({super.key, required this.requestId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authNotifierProvider).user;
    final isDonor = user?.isDonor ?? false;

    return Scaffold(
      appBar: AppBar(
          title: Text(isDonor ? 'Show QR to Seeker' : 'Scan Donor QR')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child:
            isDonor ? _DonorQr(requestId: requestId) : _SeekerScanner(requestId: requestId, ref: ref),
      ),
    );
  }
}

// ─── Donor: Display QR ───────────────────────────────────────────────────────

class _DonorQr extends StatelessWidget {
  final String requestId;
  const _DonorQr({required this.requestId});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Ask the seeker to scan this code',
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center),
        const SizedBox(height: 40),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: QrImageView(
            data: requestId,
            version: QrVersions.auto,
            size: 250,
            backgroundColor: Colors.white,
          ),
        ),
        const SizedBox(height: 24),
        Text('Request ID: $requestId',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppTheme.textSecondary)),
      ],
    );
  }
}

// ─── Seeker: Scan QR ─────────────────────────────────────────────────────────

class _SeekerScanner extends StatefulWidget {
  final String requestId;
  final WidgetRef ref;
  const _SeekerScanner({required this.requestId, required this.ref});

  @override
  State<_SeekerScanner> createState() => _SeekerScannerState();
}

class _SeekerScannerState extends State<_SeekerScanner> {
  bool _scanned = false;

  void _onDetect(BarcodeCapture capture) async {
    if (_scanned) return;
    final barcode = capture.barcodes.first.rawValue;
    if (barcode == widget.requestId) {
      _scanned = true;
      await widget.ref
          .read(requestNotifierProvider.notifier)
          .completeRequest(widget.requestId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 Donation confirmed! Thank you!'),
            backgroundColor: AppTheme.success,
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Scan the donor\'s QR code\nto confirm the donation.',
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center),
        const SizedBox(height: 24),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: MobileScanner(onDetect: _onDetect),
          ),
        ),
      ],
    );
  }
}
