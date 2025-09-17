import 'package:app_example/preferences/converters/user_profile_converter.dart';
import 'package:app_example/services/app_settings_service.dart';
import 'package:app_example/ui/widgets/reset_button.dart';
import 'package:app_example/ui/widgets/section_header.dart';
import 'package:flutter/material.dart';

class RegularSettingsPage extends StatelessWidget {
  const RegularSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = appSettings.regular;

    return Scaffold(
      appBar: AppBar(title: const Text('Regular Settings')),
      body: ListenableBuilder(
        listenable: settings,
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.only(bottom: 80),
            children: [
              const SectionHeader('General'),
              SwitchListTile(
                title: const Text('Is First Launch'),
                value: settings.isFirstLaunch,
                onChanged: settings.setIsFirstLaunch,
              ),

              // --- StreamBuilder Example ---
              StreamBuilder<int>(
                stream: settings.launchCountStream,
                builder: (context, snapshot) {
                  return ListTile(
                    title: const Text('Launch Count (from Stream)'),
                    subtitle: Text('App has been launched ${snapshot.data ?? 0} times.'),
                    trailing: IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () => settings.setLaunchCount(settings.launchCount + 1),
                    ),
                  );
                },
              ),

              const SectionHeader('Appearance'),
              ListTile(
                title: const Text('Theme'),
                trailing: DropdownButton<ThemeMode>(
                  value: settings.themeMode,
                  onChanged: (v) => settings.setThemeMode(v!),
                  items: const [
                    DropdownMenuItem(value: ThemeMode.system, child: Text('System')),
                    DropdownMenuItem(value: ThemeMode.light, child: Text('Light')),
                    DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark')),
                  ],
                ),
              ),
              ListTile(
                title: const Text('Accent Color'),
                trailing: CircleAvatar(backgroundColor: settings.accentColor),
                onTap: () => settings.setAccentColor(
                  Colors.primaries[(settings.accentColor?.toARGB32() ?? 0) %
                      Colors.primaries.length],
                ),
              ),

              const SectionHeader('User Data'),
              ListTile(
                title: const Text('Username'),
                subtitle: Text(settings.username),
                onTap: () => settings.setUsername('user_${DateTime.now().second}'),
              ),
              ListTile(
                title: const Text('User Profile (Custom Object)'),
                subtitle: Text(settings.userProfile?.name ?? 'Not set'),
                onTap: () =>
                    settings.setUserProfile(UserProfile(name: 'Alice', email: 'alice@example.com')),
                onLongPress: settings.removeUserProfile,
              ),

              ResetButton(onPressed: settings.removeAll),
            ],
          );
        },
      ),
    );
  }
}
