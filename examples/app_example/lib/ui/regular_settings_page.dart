import 'package:app_example/preferences/app_settings.dart';
import 'package:app_example/preferences/converters/user_profile_converter.dart';
import 'package:app_example/services/app_settings_service.dart';
import 'package:app_example/ui/widgets/reset_button.dart';
import 'package:app_example/ui/widgets/section_header.dart';
import 'package:flutter/material.dart';

/// Demonstrates every AppSettings field via ChangeNotifier + ListenableBuilder.
/// The entire page rebuilds whenever any setting changes — including after a
/// storage load triggered by refresh().
class RegularSettingsPage extends StatelessWidget {
  const RegularSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final s = appSettings.regular;

    return Scaffold(
      appBar: AppBar(title: const Text('Regular Settings')),
      body: ListenableBuilder(
        listenable: s,
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.only(bottom: 80),
            children: [
              // ---- Primitives ----
              const SectionHeader('Primitives'),
              ListTile(
                title: const Text('Username'),
                subtitle: Text(s.username),
                trailing: const Icon(Icons.edit),
                onTap: () => s.setUsername('user_${DateTime.now().second}'),
                onLongPress: s.removeUsername,
              ),
              ListTile(
                title: const Text('Theme Opacity'),
                subtitle: Slider(
                  value: s.themeOpacity,
                  onChanged: s.setThemeOpacity,
                ),
              ),
              SwitchListTile(
                title: const Text('Is First Launch'),
                value: s.isFirstLaunch,
                onChanged: s.setIsFirstLaunch,
              ),
              ListTile(
                title: const Text('Last Notification ID (nullable int)'),
                subtitle: Text(s.lastNotificationId?.toString() ?? 'null'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () => s.setLastNotificationId(
                        (s.lastNotificationId ?? 0) + 1,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: s.removeLastNotificationId,
                    ),
                  ],
                ),
              ),

              // ---- Collections ----
              const SectionHeader('Collections'),
              ListTile(
                title: const Text('Bookmarked Article IDs (List<String>)'),
                subtitle: Text(
                  s.bookmarkedArticleIds.isEmpty ? 'empty' : s.bookmarkedArticleIds.join(', '),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () => s.setBookmarkedArticleIds([
                        ...s.bookmarkedArticleIds,
                        'article-${DateTime.now().second}',
                      ]),
                    ),
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: s.removeBookmarkedArticleIds,
                    ),
                  ],
                ),
              ),
              ListTile(
                title: const Text('Favourite Category IDs (Set<int>)'),
                subtitle: Text(
                  s.favoriteCategoryIds.isEmpty ? 'empty' : s.favoriteCategoryIds.toString(),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () => s.setFavoriteCategoryIds({
                        ...s.favoriteCategoryIds,
                        DateTime.now().second,
                      }),
                    ),
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: s.removeFavoriteCategoryIds,
                    ),
                  ],
                ),
              ),
              ListTile(
                title: const Text('User Flags (Map<String, String>)'),
                subtitle: Text(
                  s.userFlags.isEmpty ? 'empty' : s.userFlags.toString(),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () => s.setUserFlags({
                        ...s.userFlags,
                        'flag_${DateTime.now().second}': 'on',
                      }),
                    ),
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: s.removeUserFlags,
                    ),
                  ],
                ),
              ),

              // ---- Appearance ----
              const SectionHeader('Appearance  (Core Dart & Flutter types)'),
              ListTile(
                title: const Text('Theme Mode (ThemeMode enum)'),
                subtitle: Text(s.themeMode.name),
                trailing: DropdownButton<ThemeMode>(
                  value: s.themeMode,
                  onChanged: (v) => s.setThemeMode(v!),
                  items: ThemeMode.values
                      .map(
                        (m) => DropdownMenuItem(
                          value: m,
                          child: Text(m.name),
                        ),
                      )
                      .toList(),
                ),
              ),
              ListTile(
                title: const Text('Accent Color (Color via PrefConverter)'),
                subtitle: Text(s.accentColor?.toString() ?? 'null'),
                trailing: CircleAvatar(
                  backgroundColor: s.accentColor ?? Colors.transparent,
                  child: s.accentColor == null
                      ? const Icon(Icons.palette_outlined, size: 18)
                      : null,
                ),
                onTap: () {
                  final idx = s.accentColor == null
                      ? 0
                      : (Colors.primaries.indexWhere(
                                  (c) => c.toARGB32() == s.accentColor?.toARGB32(),
                                ) +
                                1) %
                            Colors.primaries.length;
                  s.setAccentColor(Colors.primaries[idx]);
                },
                onLongPress: s.removeAccentColor,
              ),
              ListTile(
                title: const Text('Session Timeout (Duration)'),
                subtitle: Text('${s.sessionTimeout.inMinutes} minutes'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () => s.setSessionTimeout(
                        s.sessionTimeout + const Duration(minutes: 5),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () => s.setSessionTimeout(
                        s.sessionTimeout - const Duration(minutes: 5),
                      ),
                    ),
                  ],
                ),
              ),

              // ---- Enums & Records ----
              const SectionHeader('Enums & Records'),
              ListTile(
                title: const Text('Language (AppLanguage enum)'),
                subtitle: Text(s.language.name),
                trailing: DropdownButton<AppLanguage>(
                  value: s.language,
                  onChanged: (v) => s.setLanguage(v!),
                  items: AppLanguage.values
                      .map(
                        (l) => DropdownMenuItem(
                          value: l,
                          child: Text(l.name),
                        ),
                      )
                      .toList(),
                ),
              ),
              ListTile(
                title: const Text('Window Size  ({int w, int h}? record)'),
                subtitle: Text(
                  s.windowSize == null ? 'null' : '${s.windowSize!.w} × ${s.windowSize!.h}',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.aspect_ratio),
                      onPressed: () => s.setWindowSize(
                        (w: 1280 + DateTime.now().second, h: 720),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: s.removeWindowSize,
                    ),
                  ],
                ),
              ),

              // ---- Custom objects ----
              const SectionHeader('Custom Objects'),
              ListTile(
                title: const Text('User Profile (UserProfile via PrefConverter)'),
                subtitle: Text(
                  s.userProfile == null
                      ? 'null'
                      : '${s.userProfile!.name} — ${s.userProfile!.email}',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.person_add),
                      onPressed: () => s.setUserProfile(
                        UserProfile(
                          name: 'Alice',
                          email: 'alice@example.com',
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: s.removeUserProfile,
                    ),
                  ],
                ),
              ),

              // ---- Feature Showcase ----
              const SectionHeader('Feature Showcase'),

              // Custom key: @PrefEntry(key: 'launch_counter')
              // Custom stream: @PrefEntry(streamer: 'on{{Name}}Updated')
              // Stream updates shown in StreamDemoPage; here via ChangeNotifier.
              ListTile(
                title: const Text(
                  'Launch Count  (@PrefEntry key + stream template)',
                ),
                subtitle: Text(
                  "key='launch_counter'  stream=onLaunchCountUpdated\n"
                  'Value: ${s.launchCount}',
                ),
                isThreeLine: true,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () => s.setLaunchCount(s.launchCount + 1),
                    ),
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: s.removeLaunchCount,
                    ),
                  ],
                ),
              ),

              // Read-only: @PrefEntry(readOnly: true) — no setter or remover.
              ListTile(
                title: const Text(
                  'Install ID  (@PrefEntry readOnly: true)',
                ),
                subtitle: Text(s.installId),
                trailing: const Chip(label: Text('read-only')),
              ),

              ResetButton(onPressed: s.removeAll),
            ],
          );
        },
      ),
    );
  }
}
