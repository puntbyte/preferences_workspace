import 'package:flutter/material.dart';

import '../../core/di/injection.dart';
import '../../data/preferences/regular_app_settings.dart';
import 'widgets/color_picker_tile.dart';
import 'widgets/map_editor_tile.dart';
import 'widgets/section_header.dart';

class RegularSettingsPage extends StatelessWidget {
  const RegularSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = getIt<RegularAppSettings>();

    return Scaffold(
      appBar: AppBar(title: const Text('Regular Settings')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        children: [
          const SectionHeader('Appearance'),

          // Wrap widgets that depend on settings in a ListenableBuilder
          ListenableBuilder(
            listenable: settings,
            builder: (context, child) {
              return ListTile(
                title: const Text('Theme'),
                trailing: DropdownButton<ThemeMode>(
                  value: settings.themeMode,
                  onChanged: (v) => settings.setThemeMode(v!),
                  items: const [
                    DropdownMenuItem(
                      value: ThemeMode.system,
                      child: Text('System'),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.light,
                      child: Text('Light'),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.dark,
                      child: Text('Dark'),
                    ),
                  ],
                ),
              );
            },
          ),

          ListenableBuilder(
            listenable: settings,
            builder: (context, child) {
              return ColorPickerTile(
                title: 'Accent Color',
                color: settings.accentColor != null
                    ? Color(settings.accentColor!)
                    : null,
                onColorChanged: (value) =>
                    settings.setAccentColor(value.toARGB32()),
                onColorCleared: settings.removeAccentColor,
              );
            },
          ),

          const SectionHeader('Content & Localization'),

          ListenableBuilder(
            listenable: settings,
            builder: (context, child) {
              return SwitchListTile(
                title: const Text('Auto-play videos'),
                value: settings.autoPlayVideos,
                onChanged: settings.setAutoPlayVideos,
              );
            },
          ),

          // You can continue this pattern for all other widgets...
          const SectionHeader('UI State'),

          ListenableBuilder(
            listenable: settings,
            builder: (context, child) {
              return MapEditorTile(
                title: 'View Preferences',
                preferences: settings.viewPreferences,
                onChanged: settings.setViewPreferences,
              );
            },
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: FilledButton.tonal(
              onPressed: () => settings.clear(),
              child: const Text('Reset All to Defaults'),
            ),
          ),
        ],
      ),
    );
  }
}
