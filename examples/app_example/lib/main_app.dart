import 'package:flutter/material.dart';

import 'core/di/injection.dart';
import 'core/theme/app_theme.dart';
import 'data/preferences/regular_app_settings.dart';
import 'presentation/home/home_page.dart';

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final RegularAppSettings _settings = getIt<RegularAppSettings>();

  // Local state for theme-related properties
  late ThemeMode _themeMode;
  late Color? _accentColor;

  @override
  void initState() {
    super.initState();
    // Initialize local state from settings
    _themeMode = _settings.themeMode;
    _accentColor = _settings.accentColor;

    // Add the listener
    _settings.addListener(_onSettingsChanged);
  }

  @override
  void dispose() {
    _settings.removeListener(_onSettingsChanged);
    super.dispose();
  }

  // This listener now selectively checks for changes that affect the theme.
  void _onSettingsChanged() {
    // Check if theme-specific settings have changed
    if (_themeMode != _settings.themeMode || _accentColor != _settings.accentColor) {
      if (mounted) {
        // Only call setState if a theme property changed
        setState(() {
          _themeMode = _settings.themeMode;
          _accentColor = _settings.accentColor;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Preferences Demo',
      debugShowCheckedModeBanner: false,
      // The theme is now driven by the local state, not a direct call to settings.
      theme: AppTheme.light(_accentColor),
      darkTheme: AppTheme.dark(_accentColor),
      themeMode: _themeMode,
      home: const HomePage(),
    );
  }
}