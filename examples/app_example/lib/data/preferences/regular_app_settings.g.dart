// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: type=lint, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member, no_leading_underscores_for_local_identifiers

part of 'regular_app_settings.dart';

// **************************************************************************
// PreferenceGenerator
// **************************************************************************

class _RegularAppSettingsKeys {
  static const themeMode = 'theme_mode';

  static const fontSize = 'font_size';

  static const accentColor = 'accent_color';

  static const appLanguage = 'app_language';

  static const lastSeenArticleId = 'last_seen_article_id';

  static const bookmarkedArticleIds = 'bookmarked_ids';

  static const userProfile = 'user_profile_data';

  static const viewPreferences = 'view_preferences_map';

  static const windowPosition = 'window_position';

  static const itemsPerPage = 'items_per_page';

  static const autoPlayVideos = 'autoPlayVideos';

  static const showTutorial = 'showTutorial';
}

mixin _$RegularAppSettings {
  Future<void> reload();
  Future<void> clear();
  ThemeMode get themeMode;
  Future<ThemeMode> themeModeAsync();
  Future<void> setThemeMode(ThemeMode value);
  Future<void> removeThemeMode();
  AppFontSize get fontSize;
  Future<AppFontSize> fontSizeAsync();
  Future<void> setFontSize(AppFontSize value);
  Future<void> removeFontSize();
  Color? get accentColor;
  Future<Color?> accentColorAsync();
  Future<void> setAccentColor(Color value);
  Future<void> removeAccentColor();
  AppLanguage get appLanguage;
  Future<AppLanguage> appLanguageAsync();
  Future<void> setAppLanguage(AppLanguage value);
  Future<void> removeAppLanguage();
  String? get lastSeenArticleId;
  Future<String?> lastSeenArticleIdAsync();
  Future<void> setLastSeenArticleId(String value);
  Future<void> removeLastSeenArticleId();
  List<String> get bookmarkedArticleIds;
  Future<List<String>> bookmarkedArticleIdsAsync();
  Future<void> setBookmarkedArticleIds(List<String> value);
  Future<void> removeBookmarkedArticleIds();
  Map<String, dynamic>? get userProfile;
  Future<Map<String, dynamic>?> userProfileAsync();
  Future<void> setUserProfile(Map<String, dynamic> value);
  Future<void> removeUserProfile();
  Map<String, String> get viewPreferences;
  Future<Map<String, String>> viewPreferencesAsync();
  Future<void> setViewPreferences(Map<String, String> value);
  Future<void> removeViewPreferences();
  ({int height, int width, int x, int y})? get windowPosition;
  Future<({int height, int width, int x, int y})?> windowPositionAsync();
  Future<void> setWindowPosition(({int height, int width, int x, int y}) value);
  Future<void> removeWindowPosition();
  int get itemsPerPage;
  Future<int> itemsPerPageAsync();
  Future<void> setItemsPerPage(int value);
  Future<void> removeItemsPerPage();
  bool get autoPlayVideos;
  Future<bool> autoPlayVideosAsync();
  Future<void> setAutoPlayVideos(bool value);
  Future<void> removeAutoPlayVideos();
  bool get showTutorial;
  Future<bool> showTutorialAsync();
  Future<void> setShowTutorial(bool value);
  Future<void> removeShowTutorial();
}

class _RegularAppSettings extends ChangeNotifier implements RegularAppSettings {
  _RegularAppSettings(
    PreferenceAdapter this._adapter, {
    ThemeMode themeMode = ThemeMode.system,
    AppFontSize fontSize = AppFontSize.medium,
    Color? accentColor,
    AppLanguage appLanguage = AppLanguage.english,
    String? lastSeenArticleId,
    List<String> bookmarkedArticleIds = const [],
    Map<String, dynamic>? userProfile,
    Map<String, String> viewPreferences = const {
      'sortOrder': 'desc',
      'showImages': 'true',
    },
    ({int height, int width, int x, int y})? windowPosition,
    int itemsPerPage = 20,
    bool autoPlayVideos = true,
    bool showTutorial = true,
  }) : _themeMode = themeMode,
       _fontSize = fontSize,
       _accentColor = accentColor,
       _appLanguage = appLanguage,
       _lastSeenArticleId = lastSeenArticleId,
       _bookmarkedArticleIds = bookmarkedArticleIds,
       _userProfile = userProfile,
       _viewPreferences = viewPreferences,
       _windowPosition = windowPosition,
       _itemsPerPage = itemsPerPage,
       _autoPlayVideos = autoPlayVideos,
       _showTutorial = showTutorial;

  final PreferenceAdapter _adapter;

  ThemeMode _themeMode;

  AppFontSize _fontSize;

  Color? _accentColor;

  AppLanguage _appLanguage;

  String? _lastSeenArticleId;

  List<String> _bookmarkedArticleIds;

  Map<String, dynamic>? _userProfile;

  Map<String, String> _viewPreferences;

  ({int height, int width, int x, int y})? _windowPosition;

  int _itemsPerPage;

  bool _autoPlayVideos;

  bool _showTutorial;

  Future<void> _load() async {
    bool P_changed = false;
    final rawValueForThemeMode = await _adapter.get<String?>(
      _RegularAppSettingsKeys.themeMode,
    );
    final newValueForThemeMode =
        ThemeMode.values.asNameMap()[rawValueForThemeMode] ?? ThemeMode.system;
    if (_themeMode != newValueForThemeMode) {
      _themeMode = newValueForThemeMode;
      P_changed = true;
    }
    final rawValueForFontSize = await _adapter.get<String?>(
      _RegularAppSettingsKeys.fontSize,
    );
    final newValueForFontSize =
        AppFontSize.values.asNameMap()[rawValueForFontSize] ??
        AppFontSize.medium;
    if (_fontSize != newValueForFontSize) {
      _fontSize = newValueForFontSize;
      P_changed = true;
    }
    final rawValueForAccentColor = await _adapter.get<Color?>(
      _RegularAppSettingsKeys.accentColor,
    );
    final newValueForAccentColor = rawValueForAccentColor ?? null;
    if (_accentColor != newValueForAccentColor) {
      _accentColor = newValueForAccentColor;
      P_changed = true;
    }
    final rawValueForAppLanguage = await _adapter.get<String?>(
      _RegularAppSettingsKeys.appLanguage,
    );
    final newValueForAppLanguage =
        AppLanguage.values.asNameMap()[rawValueForAppLanguage] ??
        AppLanguage.english;
    if (_appLanguage != newValueForAppLanguage) {
      _appLanguage = newValueForAppLanguage;
      P_changed = true;
    }
    final rawValueForLastSeenArticleId = await _adapter.get<String?>(
      _RegularAppSettingsKeys.lastSeenArticleId,
    );
    final newValueForLastSeenArticleId = rawValueForLastSeenArticleId ?? null;
    if (_lastSeenArticleId != newValueForLastSeenArticleId) {
      _lastSeenArticleId = newValueForLastSeenArticleId;
      P_changed = true;
    }
    final rawValueForBookmarkedArticleIds = await _adapter.get<List<String>>(
      _RegularAppSettingsKeys.bookmarkedArticleIds,
    );
    final newValueForBookmarkedArticleIds =
        rawValueForBookmarkedArticleIds ?? const [];
    if (_bookmarkedArticleIds != newValueForBookmarkedArticleIds) {
      _bookmarkedArticleIds = newValueForBookmarkedArticleIds;
      P_changed = true;
    }
    final rawValueForUserProfile = await _adapter.get<Map<String, dynamic>?>(
      _RegularAppSettingsKeys.userProfile,
    );
    final newValueForUserProfile = rawValueForUserProfile ?? null;
    if (_userProfile != newValueForUserProfile) {
      _userProfile = newValueForUserProfile;
      P_changed = true;
    }
    final rawValueForViewPreferences = await _adapter.get<Map<String, String>>(
      _RegularAppSettingsKeys.viewPreferences,
    );
    final newValueForViewPreferences =
        rawValueForViewPreferences ??
        const {'sortOrder': 'desc', 'showImages': 'true'};
    if (_viewPreferences != newValueForViewPreferences) {
      _viewPreferences = newValueForViewPreferences;
      P_changed = true;
    }
    final rawValueForWindowPosition = await _adapter.get<Map<String, dynamic>?>(
      _RegularAppSettingsKeys.windowPosition,
    );
    final newValueForWindowPosition = rawValueForWindowPosition == null
        ? null
        : (
                height: (rawValueForWindowPosition['height'] as int?) ?? 0,
                width: (rawValueForWindowPosition['width'] as int?) ?? 0,
                x: (rawValueForWindowPosition['x'] as int?) ?? 0,
                y: (rawValueForWindowPosition['y'] as int?) ?? 0,
              ) ??
              null;
    if (_windowPosition != newValueForWindowPosition) {
      _windowPosition = newValueForWindowPosition;
      P_changed = true;
    }
    final rawValueForItemsPerPage = await _adapter.get<int>(
      _RegularAppSettingsKeys.itemsPerPage,
    );
    final newValueForItemsPerPage = rawValueForItemsPerPage ?? 20;
    if (_itemsPerPage != newValueForItemsPerPage) {
      _itemsPerPage = newValueForItemsPerPage;
      P_changed = true;
    }
    final rawValueForAutoPlayVideos = await _adapter.get<bool>(
      _RegularAppSettingsKeys.autoPlayVideos,
    );
    final newValueForAutoPlayVideos = rawValueForAutoPlayVideos ?? true;
    if (_autoPlayVideos != newValueForAutoPlayVideos) {
      _autoPlayVideos = newValueForAutoPlayVideos;
      P_changed = true;
    }
    final rawValueForShowTutorial = await _adapter.get<bool>(
      _RegularAppSettingsKeys.showTutorial,
    );
    final newValueForShowTutorial = rawValueForShowTutorial ?? true;
    if (_showTutorial != newValueForShowTutorial) {
      _showTutorial = newValueForShowTutorial;
      P_changed = true;
    }
    if (P_changed) {
      notifyListeners();
    }
  }

  @override
  Future<void> reload() async {
    await _load();
  }

  @override
  Future<void> clear() async {
    await _adapter.clear();
    await _load();
  }

  @override
  ThemeMode get themeMode => _themeMode;

  @override
  Future<ThemeMode> themeModeAsync() async {
    await reload();
    return _themeMode;
  }

  @override
  Future<void> setThemeMode(ThemeMode value) async {
    if (_themeMode != value) {
      _themeMode = value;
      final toStore = value.name;
      await _adapter.set<String>(_RegularAppSettingsKeys.themeMode, toStore);
      notifyListeners();
    }
  }

  @override
  Future<void> removeThemeMode() async {
    final defaultValue = ThemeMode.system;
    if (_themeMode != defaultValue) {
      _themeMode = defaultValue;
      await _adapter.remove(_RegularAppSettingsKeys.themeMode);
      notifyListeners();
    }
  }

  @override
  AppFontSize get fontSize => _fontSize;

  @override
  Future<AppFontSize> fontSizeAsync() async {
    await reload();
    return _fontSize;
  }

  @override
  Future<void> setFontSize(AppFontSize value) async {
    if (_fontSize != value) {
      _fontSize = value;
      final toStore = value.name;
      await _adapter.set<String>(_RegularAppSettingsKeys.fontSize, toStore);
      notifyListeners();
    }
  }

  @override
  Future<void> removeFontSize() async {
    final defaultValue = AppFontSize.medium;
    if (_fontSize != defaultValue) {
      _fontSize = defaultValue;
      await _adapter.remove(_RegularAppSettingsKeys.fontSize);
      notifyListeners();
    }
  }

  @override
  Color? get accentColor => _accentColor;

  @override
  Future<Color?> accentColorAsync() async {
    await reload();
    return _accentColor;
  }

  @override
  Future<void> setAccentColor(Color value) async {
    if (_accentColor != value) {
      _accentColor = value;
      final toStore = value;
      await _adapter.set<Color>(_RegularAppSettingsKeys.accentColor, toStore);
      notifyListeners();
    }
  }

  @override
  Future<void> removeAccentColor() async {
    final defaultValue = null;
    if (_accentColor != defaultValue) {
      _accentColor = defaultValue;
      await _adapter.remove(_RegularAppSettingsKeys.accentColor);
      notifyListeners();
    }
  }

  @override
  AppLanguage get appLanguage => _appLanguage;

  @override
  Future<AppLanguage> appLanguageAsync() async {
    await reload();
    return _appLanguage;
  }

  @override
  Future<void> setAppLanguage(AppLanguage value) async {
    if (_appLanguage != value) {
      _appLanguage = value;
      final toStore = value.name;
      await _adapter.set<String>(_RegularAppSettingsKeys.appLanguage, toStore);
      notifyListeners();
    }
  }

  @override
  Future<void> removeAppLanguage() async {
    final defaultValue = AppLanguage.english;
    if (_appLanguage != defaultValue) {
      _appLanguage = defaultValue;
      await _adapter.remove(_RegularAppSettingsKeys.appLanguage);
      notifyListeners();
    }
  }

  @override
  String? get lastSeenArticleId => _lastSeenArticleId;

  @override
  Future<String?> lastSeenArticleIdAsync() async {
    await reload();
    return _lastSeenArticleId;
  }

  @override
  Future<void> setLastSeenArticleId(String value) async {
    if (_lastSeenArticleId != value) {
      _lastSeenArticleId = value;
      final toStore = value;
      await _adapter.set<String>(
        _RegularAppSettingsKeys.lastSeenArticleId,
        toStore,
      );
      notifyListeners();
    }
  }

  @override
  Future<void> removeLastSeenArticleId() async {
    final defaultValue = null;
    if (_lastSeenArticleId != defaultValue) {
      _lastSeenArticleId = defaultValue;
      await _adapter.remove(_RegularAppSettingsKeys.lastSeenArticleId);
      notifyListeners();
    }
  }

  @override
  List<String> get bookmarkedArticleIds => _bookmarkedArticleIds;

  @override
  Future<List<String>> bookmarkedArticleIdsAsync() async {
    await reload();
    return _bookmarkedArticleIds;
  }

  @override
  Future<void> setBookmarkedArticleIds(List<String> value) async {
    if (_bookmarkedArticleIds != value) {
      _bookmarkedArticleIds = value;
      final toStore = value;
      await _adapter.set<List<String>>(
        _RegularAppSettingsKeys.bookmarkedArticleIds,
        toStore,
      );
      notifyListeners();
    }
  }

  @override
  Future<void> removeBookmarkedArticleIds() async {
    final defaultValue = const <String>[];
    if (_bookmarkedArticleIds != defaultValue) {
      _bookmarkedArticleIds = defaultValue;
      await _adapter.remove(_RegularAppSettingsKeys.bookmarkedArticleIds);
      notifyListeners();
    }
  }

  @override
  Map<String, dynamic>? get userProfile => _userProfile;

  @override
  Future<Map<String, dynamic>?> userProfileAsync() async {
    await reload();
    return _userProfile;
  }

  @override
  Future<void> setUserProfile(Map<String, dynamic> value) async {
    if (_userProfile != value) {
      _userProfile = value;
      final toStore = value;
      await _adapter.set<Map<String, dynamic>>(
        _RegularAppSettingsKeys.userProfile,
        toStore,
      );
      notifyListeners();
    }
  }

  @override
  Future<void> removeUserProfile() async {
    final defaultValue = null;
    if (_userProfile != defaultValue) {
      _userProfile = defaultValue;
      await _adapter.remove(_RegularAppSettingsKeys.userProfile);
      notifyListeners();
    }
  }

  @override
  Map<String, String> get viewPreferences => _viewPreferences;

  @override
  Future<Map<String, String>> viewPreferencesAsync() async {
    await reload();
    return _viewPreferences;
  }

  @override
  Future<void> setViewPreferences(Map<String, String> value) async {
    if (_viewPreferences != value) {
      _viewPreferences = value;
      final toStore = value;
      await _adapter.set<Map<String, String>>(
        _RegularAppSettingsKeys.viewPreferences,
        toStore,
      );
      notifyListeners();
    }
  }

  @override
  Future<void> removeViewPreferences() async {
    final defaultValue = const {'sortOrder': 'desc', 'showImages': 'true'};
    if (_viewPreferences != defaultValue) {
      _viewPreferences = defaultValue;
      await _adapter.remove(_RegularAppSettingsKeys.viewPreferences);
      notifyListeners();
    }
  }

  @override
  ({int height, int width, int x, int y})? get windowPosition =>
      _windowPosition;

  @override
  Future<({int height, int width, int x, int y})?> windowPositionAsync() async {
    await reload();
    return _windowPosition;
  }

  @override
  Future<void> setWindowPosition(
    ({int height, int width, int x, int y}) value,
  ) async {
    if (_windowPosition != value) {
      _windowPosition = value;
      final toStore = {
        'height': value.height,
        'width': value.width,
        'x': value.x,
        'y': value.y,
      };
      await _adapter.set<Map<String, dynamic>>(
        _RegularAppSettingsKeys.windowPosition,
        toStore,
      );
      notifyListeners();
    }
  }

  @override
  Future<void> removeWindowPosition() async {
    final defaultValue = null;
    if (_windowPosition != defaultValue) {
      _windowPosition = defaultValue;
      await _adapter.remove(_RegularAppSettingsKeys.windowPosition);
      notifyListeners();
    }
  }

  @override
  int get itemsPerPage => _itemsPerPage;

  @override
  Future<int> itemsPerPageAsync() async {
    await reload();
    return _itemsPerPage;
  }

  @override
  Future<void> setItemsPerPage(int value) async {
    if (_itemsPerPage != value) {
      _itemsPerPage = value;
      final toStore = value;
      await _adapter.set<int>(_RegularAppSettingsKeys.itemsPerPage, toStore);
      notifyListeners();
    }
  }

  @override
  Future<void> removeItemsPerPage() async {
    final defaultValue = 20;
    if (_itemsPerPage != defaultValue) {
      _itemsPerPage = defaultValue;
      await _adapter.remove(_RegularAppSettingsKeys.itemsPerPage);
      notifyListeners();
    }
  }

  @override
  bool get autoPlayVideos => _autoPlayVideos;

  @override
  Future<bool> autoPlayVideosAsync() async {
    await reload();
    return _autoPlayVideos;
  }

  @override
  Future<void> setAutoPlayVideos(bool value) async {
    if (_autoPlayVideos != value) {
      _autoPlayVideos = value;
      final toStore = value;
      await _adapter.set<bool>(_RegularAppSettingsKeys.autoPlayVideos, toStore);
      notifyListeners();
    }
  }

  @override
  Future<void> removeAutoPlayVideos() async {
    final defaultValue = true;
    if (_autoPlayVideos != defaultValue) {
      _autoPlayVideos = defaultValue;
      await _adapter.remove(_RegularAppSettingsKeys.autoPlayVideos);
      notifyListeners();
    }
  }

  @override
  bool get showTutorial => _showTutorial;

  @override
  Future<bool> showTutorialAsync() async {
    await reload();
    return _showTutorial;
  }

  @override
  Future<void> setShowTutorial(bool value) async {
    if (_showTutorial != value) {
      _showTutorial = value;
      final toStore = value;
      await _adapter.set<bool>(_RegularAppSettingsKeys.showTutorial, toStore);
      notifyListeners();
    }
  }

  @override
  Future<void> removeShowTutorial() async {
    final defaultValue = true;
    if (_showTutorial != defaultValue) {
      _showTutorial = defaultValue;
      await _adapter.remove(_RegularAppSettingsKeys.showTutorial);
      notifyListeners();
    }
  }
}
