import 'package:app_example/preferences/secure_settings.dart';
import 'package:app_example/services/app_settings_service.dart';
import 'package:app_example/ui/widgets/reset_button.dart';
import 'package:app_example/ui/widgets/section_header.dart';
import 'package:flutter/material.dart';

/// Demonstrates SecureSettings features:
/// - @PrefsModule with keyCase: KeyCase.snake (storage keys are snake_case)
/// - Streams opted-in per-entry via @PrefEntry(streamer: ...)
/// - Inline toStorage/fromStorage serialization
/// - ChangeNotifier for non-streaming entries
class SecureSettingsPage extends StatelessWidget {
  const SecureSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final s = appSettings.secure;

    return Scaffold(
      appBar: AppBar(title: const Text('Secure Settings')),
      body: ListenableBuilder(
        listenable: s,
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.only(bottom: 80),
            children: [
              const SectionHeader('Authentication'),

              // Stream: watchAuthTokenStream
              // @PrefEntry(streamer: 'watch{{Name}}Stream')
              // storage key: 'auth_token'  (KeyCase.snake)
              StreamBuilder<String?>(
                stream: s.watchAuthTokenStream,
                builder: (context, snap) => ListTile(
                  title: const Text(
                    'Auth Token  (watchAuthTokenStream)',
                  ),
                  subtitle: Text(
                    snap.data ?? 'null',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      color: snap.hasData
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.outline,
                    ),
                  ),
                  leading: Icon(
                    snap.hasData ? Icons.circle : Icons.circle_outlined,
                    color: snap.hasData ? Colors.green : Theme.of(context).colorScheme.outline,
                    size: 12,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.vpn_key),
                        tooltip: 'Set token',
                        onPressed: () => s.setAuthToken(
                          'tok_${DateTime.now().millisecondsSinceEpoch}',
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.clear),
                        tooltip: 'Remove token',
                        onPressed: s.removeAuthToken,
                      ),
                    ],
                  ),
                ),
              ),

              // No stream — observable only via ChangeNotifier.
              // Uses inline toStorage/fromStorage for JSON serialization.
              // storage key: 'api_session'  (KeyCase.snake)
              ListTile(
                title: const Text(
                  'API Session  (inline toStorage/fromStorage)',
                ),
                subtitle: Text(
                  s.apiSession == null
                      ? 'null'
                      : 'token=${s.apiSession!.token}\n'
                            'expiry=${s.apiSession!.expiry.toLocal()}',
                  maxLines: 2,
                ),
                isThreeLine: s.apiSession != null,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.add),
                      tooltip: 'Set session',
                      onPressed: () => s.setApiSession(
                        ApiSession(
                          token: 'sess_${DateTime.now().second}',
                          expiry: DateTime.now().add(const Duration(days: 7)),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.clear),
                      tooltip: 'Remove session',
                      onPressed: s.removeApiSession,
                    ),
                  ],
                ),
              ),

              const SectionHeader('Security'),

              // Stream: areBiometricsEnabledStream
              // @PrefEntry(streamer: '{{name}}Stream')
              // storage key: 'are_biometrics_enabled'  (KeyCase.snake)
              StreamBuilder<bool>(
                stream: s.areBiometricsEnabledStream,
                builder: (context, snap) => SwitchListTile(
                  title: const Text(
                    'Biometrics Enabled  (areBiometricsEnabledStream)',
                  ),
                  subtitle: Text(
                    'Stream value: ${snap.data?.toString() ?? "(no event yet)"}',
                  ),
                  secondary: Icon(
                    snap.hasData ? Icons.circle : Icons.circle_outlined,
                    color: snap.hasData ? Colors.green : Theme.of(context).colorScheme.outline,
                    size: 12,
                  ),
                  value: s.areBiometricsEnabled,
                  onChanged: s.setAreBiometricsEnabled,
                ),
              ),

              const SectionHeader('Storage Key Casing'),
              const ListTile(
                title: Text('keyCase: KeyCase.snake'),
                subtitle: Text(
                  'authToken       → "auth_token"\n'
                  'apiSession      → "api_session"\n'
                  'areBiometrics.. → "are_biometrics_enabled"',
                ),
                isThreeLine: true,
              ),

              ResetButton(onPressed: s.removeAll),
            ],
          );
        },
      ),
    );
  }
}
