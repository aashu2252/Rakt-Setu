// lib/presentation/screens/request/request_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/request_provider.dart';

class RequestScreen extends ConsumerStatefulWidget {
  const RequestScreen({super.key});

  @override
  ConsumerState<RequestScreen> createState() => _RequestScreenState();
}

class _RequestScreenState extends ConsumerState<RequestScreen> {
  final _hospitalCtrl = TextEditingController();
  String? _selectedBloodGroup;
  int _units = 1;
  Position? _position;

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  Future<void> _getLocation() async {
    try {
      final pos = await Geolocator.getCurrentPosition();
      setState(() => _position = pos);
    } catch (_) {}
  }

  Future<void> _submit() async {
    if (_selectedBloodGroup == null ||
        _hospitalCtrl.text.isEmpty ||
        _position == null) {
      return;
    }

    final user = ref.read(authNotifierProvider).user!;
    await ref.read(requestNotifierProvider.notifier).createRequest(
          seekerId: user.uid,
          seekerName: user.name,
          seekerPhone: user.phone,
          bloodGroup: _selectedBloodGroup!,
          unitsNeeded: _units,
          hospitalLocation:
              GeoPoint(_position!.latitude, _position!.longitude),
          hospitalName: _hospitalCtrl.text.trim(),
        );

    if (!mounted) return;
    final req = ref.read(requestNotifierProvider);
    if (req.error == null && req.activeRequest != null) {
      context.push(AppConstants.routeTracking,
          extra: req.activeRequest!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(requestNotifierProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Request Blood')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Emergency banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryRed.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.primaryRed.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      color: AppTheme.primaryRed),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Donors within 5km will be notified immediately.',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: AppTheme.primaryRed),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            // Hospital name
            TextField(
              controller: _hospitalCtrl,
              decoration: const InputDecoration(
                labelText: 'Hospital / Location Name',
                prefixIcon: Icon(Icons.local_hospital_rounded),
              ),
            ),
            const SizedBox(height: 24),
            // Blood group
            Text('Blood Group Required',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: AppConstants.bloodGroups
                  .map((bg) => ChoiceChip(
                        label: Text(bg),
                        selected: _selectedBloodGroup == bg,
                        selectedColor: AppTheme.primaryRed,
                        onSelected: (_) =>
                            setState(() => _selectedBloodGroup = bg),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 24),
            // Units
            Row(
              children: [
                Text('Units Needed: ',
                    style: Theme.of(context).textTheme.titleLarge),
                const Spacer(),
                IconButton(
                    onPressed: () =>
                        setState(() => _units = (_units - 1).clamp(1, 10)),
                    icon: const Icon(Icons.remove_circle_outline)),
                Text('$_units',
                    style: Theme.of(context).textTheme.headlineMedium),
                IconButton(
                    onPressed: () =>
                        setState(() => _units = (_units + 1).clamp(1, 10)),
                    icon: const Icon(Icons.add_circle_outline)),
              ],
            ),
            // Location status
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  _position != null ? Icons.my_location : Icons.location_off,
                  color: _position != null
                      ? AppTheme.success
                      : AppTheme.textSecondary,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  _position != null
                      ? 'Location acquired ✓'
                      : 'Getting location...',
                  style: TextStyle(
                    color: _position != null
                        ? AppTheme.success
                        : AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
            if (state.error != null) ...[
              const SizedBox(height: 12),
              Text(state.error!,
                  style: const TextStyle(color: AppTheme.lightRed)),
            ],
            const SizedBox(height: 36),
            ElevatedButton.icon(
              icon: const Icon(Icons.sos_rounded),
              label: const Text('SEND SOS — FIND DONORS NOW'),
              onPressed: (state.isLoading || _position == null) ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }
}
