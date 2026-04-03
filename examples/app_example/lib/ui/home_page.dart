import 'package:app_example/services/app_settings_service.dart';
import 'package:app_example/ui/regular_settings_page.dart';
import 'package:app_example/ui/secure_settings_page.dart';
import 'package:app_example/ui/stream_demo_page.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preferences Showcase'),
        actions: [
          // Shows _isLoaded guard working: refresh() re-reads storage once
          // and pushes any changed values to all streams.
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh all from storage',
            onPressed: () async {
              await appSettings.regular.refresh();
              await appSettings.secure.refresh();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Refreshed from storage')),
                );
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Live badge showing username via ChangeNotifier
              ListenableBuilder(
                listenable: appSettings.regular,
                builder: (context, _) => Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          'Hello, ${appSettings.regular.username}!',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Theme: ${appSettings.regular.themeMode.name}  '
                              '• Launches: ${appSettings.regular.launchCount}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                icon: const Icon(Icons.settings),
                label: const Text('Regular Settings'),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const RegularSettingsPage(),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                icon: const Icon(Icons.stream),
                label: const Text('Stream Live Demo'),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const StreamDemoPage(),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.tonalIcon(
                icon: const Icon(Icons.security),
                label: const Text('Secure Settings'),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const SecureSettingsPage(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}