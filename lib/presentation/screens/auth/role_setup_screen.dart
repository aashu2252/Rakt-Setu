// lib/presentation/screens/auth/role_setup_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';

class RoleSetupScreen extends ConsumerStatefulWidget {
  const RoleSetupScreen({super.key});

  @override
  ConsumerState<RoleSetupScreen> createState() => _RoleSetupScreenState();
}

class _RoleSetupScreenState extends ConsumerState<RoleSetupScreen> {
  final _nameCtrl = TextEditingController();
  String? _selectedRole;
  String? _selectedBloodGroup;
  DateTime? _lastDonationDate;

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty || _selectedRole == null) return;
    if (_selectedRole == 'donor' && _selectedBloodGroup == null) return;

    await ref.read(authNotifierProvider.notifier).setupProfile(
          name: _nameCtrl.text.trim(),
          role: _selectedRole!,
          bloodGroup: _selectedBloodGroup,
          lastDonationDate: _lastDonationDate,
        );
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authNotifierProvider);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text('Set Up Your Profile',
                  style: Theme.of(context).textTheme.displayMedium),
              const SizedBox(height: 8),
              Text('Tell us who you are',
                  style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 40),
              // Name
              TextField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Full Name'),
              ),
              const SizedBox(height: 24),
              // Role selection
              Text('I am a...',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              Row(
                children: [
                  _RoleCard(
                    label: 'Life Saver',
                    subtitle: 'Blood Donor',
                    icon: Icons.favorite,
                    isSelected: _selectedRole == 'donor',
                    onTap: () => setState(() => _selectedRole = 'donor'),
                  ),
                  const SizedBox(width: 16),
                  _RoleCard(
                    label: 'Help Seeker',
                    subtitle: 'Need Blood',
                    icon: Icons.local_hospital,
                    isSelected: _selectedRole == 'seeker',
                    onTap: () => setState(() => _selectedRole = 'seeker'),
                  ),
                ],
              ),
              // Donor-only fields
              if (_selectedRole == 'donor') ...[
                const SizedBox(height: 24),
                Text('Blood Group',
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
                OutlinedButton.icon(
                  icon: const Icon(Icons.calendar_today),
                  label: Text(_lastDonationDate == null
                      ? 'Last Donation Date (Optional)'
                      : 'Last donated: ${_lastDonationDate!.day}/${_lastDonationDate!.month}/${_lastDonationDate!.year}'),
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() => _lastDonationDate = picked);
                    }
                  },
                ),
              ],
              const SizedBox(height: 48),
              if (auth.error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(auth.error!,
                      style: const TextStyle(color: AppTheme.lightRed)),
                ),
              ElevatedButton(
                onPressed: auth.isLoading ? null : _save,
                child: auth.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Text('Get Started'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.primaryRed.withValues(alpha: 0.15)
                : AppTheme.cardDark,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? AppTheme.primaryRed : AppTheme.divider,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon,
                  size: 36,
                  color: isSelected ? AppTheme.primaryRed : AppTheme.textSecondary),
              const SizedBox(height: 12),
              Text(label,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isSelected ? AppTheme.primaryRed : AppTheme.textPrimary,
                  )),
              Text(subtitle,
                  style: const TextStyle(
                      fontSize: 12, color: AppTheme.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }
}
