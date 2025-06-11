import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/di/injection.dart';
import '../../data/preferences/secure_app_settings.dart';
import '../../domain/enums.dart';
import 'widgets/section_header.dart';

class SecureSettingsPage extends StatefulWidget {
  const SecureSettingsPage({super.key});

  @override
  State<SecureSettingsPage> createState() => _SecureSettingsPageState();
}

class _SecureSettingsPageState extends State<SecureSettingsPage> {
  final _settings = getIt<SecureAppSettings>();

  @override
  void initState() {
    super.initState();
    _settings.addListener(_onSettingsChanged);
  }

  @override
  void dispose() {
    _settings.removeListener(_onSettingsChanged);
    super.dispose();
  }

  void _onSettingsChanged() {
    if (mounted) setState(() {});
  }

  /// A helper to show a date picker and call a callback with the result.
  Future<void> _pickDate(
    BuildContext context,
    DateTime? initialDate,
    // This signature is correct: it expects a callback that takes a nullable DateTime.
    ValueChanged<DateTime?> onDatePicked,
  ) async {
    final date = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    // The date can be null if the user cancels.
    onDatePicked(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Secure Settings')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        children: [
          const SectionHeader('Authentication'),
          // ... (Auth Token and User Role ListTiles are correct)
          ListTile(
            title: const Text('Auth Token'),
            subtitle: Text(_settings.authToken ?? 'Not set'),
          ),
          ListTile(
            title: const Text('User Role'),
            trailing: DropdownButton<UserRole>(
              value: _settings.userRole,
              onChanged: (v) => _settings.setUserRole(v!),
              items: UserRole.values
                  .map((role) => DropdownMenuItem(
                        value: role,
                        child: Text(role.name),
                      ))
                  .toList(),
            ),
          ),

          const SectionHeader('Security'),
          // ... (Biometric and PIN Attempt ListTiles are correct)
          ListTile(
            title: const Text('Biometric Auth'),
            trailing: DropdownButton<BiometricAuth>(
              value: _settings.biometricPreference,
              onChanged: (v) => _settings.setBiometricPreference(v!),
              items: BiometricAuth.values
                  .map((auth) => DropdownMenuItem(
                        value: auth,
                        child: Text(auth.name),
                      ))
                  .toList(),
            ),
          ),
          ListTile(
            title: const Text('PIN Attempt Count'),
            subtitle: Text(_settings.pinAttemptCount.toString()),
            onTap: () {
              // Increment for demo purposes
              _settings.setPinAttemptCount(_settings.pinAttemptCount + 1);
            },
          ),

          // --- THE FIX IS IN THIS WIDGET ---
          ListTile(
            title: const Text('Account Lockout Until'),
            subtitle: Text(
              _settings.accountLockoutUntil == null
                  ? 'Not locked'
                  : DateFormat.yMd().format(_settings.accountLockoutUntil!),
            ),
            trailing: const Icon(Icons.calendar_today),
            onTap: () => _pickDate(
              context,
              _settings.accountLockoutUntil,
              // Create a new anonymous function that matches the expected signature.
              // This function correctly calls the async setter inside it.
              (newDate) {
                if (newDate == null) {
                  _settings.removeAccountLockoutUntil();
                } else {
                  _settings.setAccountLockoutUntil(newDate);
                }
              },
            ),
          ),

          // --- APPLY THE SAME FIX HERE ---
          ListTile(
            title: const Text('Session Expiry'),
            subtitle: Text(
              _settings.sessionExpiryDate == null
                  ? 'No expiry'
                  : DateFormat.yMd().format(_settings.sessionExpiryDate!),
            ),
            trailing: const Icon(Icons.calendar_today),
            onTap: () => _pickDate(
              context,
              _settings.sessionExpiryDate,
              (newDate) {
                if (newDate == null) {
                  _settings.removeSessionExpiryDate();
                } else {
                  _settings.setSessionExpiryDate(newDate);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
