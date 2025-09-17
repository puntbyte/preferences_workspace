import 'package:app_example/ui/regular_settings_page.dart';
import 'package:app_example/ui/secure_settings_page.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Preferences Showcase')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FilledButton.icon(
                icon: const Icon(Icons.settings),
                label: const Text('Regular Settings'),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const RegularSettingsPage()),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.tonalIcon(
                icon: const Icon(Icons.security),
                label: const Text('Secure Settings'),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SecureSettingsPage()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
