import 'package:app_example/preferences/secure_settings.dart';
import 'package:app_example/services/app_settings_service.dart';
import 'package:app_example/ui/widgets/reset_button.dart';
import 'package:app_example/ui/widgets/section_header.dart';
import 'package:flutter/material.dart';

class SecureSettingsPage extends StatelessWidget {
  const SecureSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = appSettings.secure;

    return Scaffold(
      appBar: AppBar(title: const Text('Secure Settings')),
      body: ListenableBuilder(
        listenable: settings,
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.only(bottom: 80),
            children: [
              const SectionHeader('Authentication'),

              // --- StreamBuilder Example ---
              StreamBuilder<String?>(
                stream: settings.authTokenStream,
                builder: (context, snapshot) {
                  return ListTile(
                    title: const Text('Auth Token (from Stream)'),
                    subtitle: Text(snapshot.data ?? 'Not set'),
                    onTap: () => settings.setAuthToken('token-${DateTime.now().toIso8601String()}'),
                    onLongPress: settings.removeAuthToken,
                  );
                },
              ),

              ListTile(
                title: const Text('API Session (Custom Object)'),
                subtitle: Text(settings.apiSession?.token ?? 'Not set'),
                onTap: () => settings.setApiSession(
                  ApiSession(
                    token: 'session-123',
                    expiry: DateTime.now().add(const Duration(days: 7)),
                  ),
                ),
                onLongPress: settings.removeApiSession,
              ),

              const SectionHeader('Security'),
              SwitchListTile(
                title: const Text('Biometrics Enabled'),
                value: settings.areBiometricsEnabled,
                onChanged: settings.setAreBiometricsEnabled,
              ),

              ResetButton(onPressed: settings.removeAll),
            ],
          );
        },
      ),
    );
  }
}
