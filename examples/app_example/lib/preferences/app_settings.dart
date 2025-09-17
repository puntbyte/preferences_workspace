import 'dart:async';

import 'package:app_example/preferences/converters/color_converter.dart';
import 'package:app_example/preferences/converters/user_profile_converter.dart';
import 'package:flutter/material.dart';
import 'package:preferences_annotation/preferences_annotation.dart';

part 'app_settings.prefs.dart';

enum AppLanguage { english, spanish, french }

@PrefsModule.reactive()
abstract class AppSettings with _$AppSettings, ChangeNotifier {
  factory AppSettings(PrefsAdapter adapter) = _AppSettings;

  AppSettings._({
    // --- Primitives ---
    String username = 'guest',
    double themeOpacity = 1.0,
    bool isFirstLaunch = true,
    int? lastNotificationId,

    // --- Collections ---
    List<String> bookmarkedArticleIds = const <String>[],
    Set<int> favoriteCategoryIds = const <int>{},
    Map<String, String> userFlags = const <String, String>{},

    // --- Core Dart & Flutter Types ---
    ThemeMode themeMode = ThemeMode.system,
    @PrefEntry(converter: ColorConverter()) Color? accentColor,
    Duration sessionTimeout = const Duration(minutes: 30),

    // --- Enums & Records ---
    AppLanguage language = AppLanguage.english,
    ({int w, int h})? windowSize,

    // --- Custom Object with PrefConverter ---
    @PrefEntry(converter: UserProfileConverter()) UserProfile? userProfile,

    // --- Feature Showcase ---
    // 1. Explicit key and streaming enabled
    @PrefEntry(key: 'launch_counter', streamer: CustomConfig(enabled: true)) int launchCount = 0,

    // 2. Read-only field
    @PrefEntry(setter: CustomConfig(enabled: false), remover: CustomConfig(enabled: false))
    final String installId = 'uuid-1234-abcd',
  });
}
