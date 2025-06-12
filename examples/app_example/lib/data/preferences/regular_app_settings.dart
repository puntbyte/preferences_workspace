import 'package:flutter/material.dart';
import 'package:preferences_annotation/preferences_annotation.dart';

import '../../domain/enums.dart';

part 'regular_app_settings.g.dart';

@PreferenceModule()
abstract class RegularAppSettings with _$RegularAppSettings, ChangeNotifier {
  factory RegularAppSettings(
    PreferenceAdapter adapter, {

    // --- Appearance ---
    @PreferenceEntry(key: 'theme_mode', defaultValue: ThemeMode.system)
    final ThemeMode themeMode,

    @PreferenceEntry(key: 'font_size', defaultValue: AppFontSize.medium)
    final AppFontSize fontSize,

    @PreferenceEntry(key: 'accent_color') final int? accentColor,

    // --- Localization & Content ---
    @PreferenceEntry(key: 'app_language', defaultValue: AppLanguage.english)
    final AppLanguage appLanguage,

    @PreferenceEntry(key: 'last_seen_article_id')
    final String? lastSeenArticleId,

    @PreferenceEntry(key: 'bookmarked_ids', defaultValue: <String>[])
    final List<String> bookmarkedArticleIds,

    // --- User Profile (Complex Object via Map) ---
    @PreferenceEntry(key: 'user_profile_data')
    final Map<String, dynamic>? userProfile,

    // --- Advanced UI State ---
    @PreferenceEntry(
      key: 'view_preferences_map',
      defaultValue: {'sortOrder': 'desc', 'showImages': 'true'},
    )
    final Map<String, String> viewPreferences,

    @PreferenceEntry(key: 'window_position')
    final ({int x, int y, int width, int height})? windowPosition,

    @PreferenceEntry(key: 'items_per_page', defaultValue: 20)
    final int itemsPerPage,

    // --- Toggles ---
    @PreferenceEntry(defaultValue: true) final bool autoPlayVideos,

    @PreferenceEntry(defaultValue: true) final bool showTutorial,
  }) = _RegularAppSettings;

  static Future<RegularAppSettings> create(PreferenceAdapter adapter) async {
    final instance = _RegularAppSettings(adapter);
    await instance._load();
    return instance;
  }
}
