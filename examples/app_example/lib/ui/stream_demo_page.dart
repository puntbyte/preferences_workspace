import 'package:app_example/preferences/app_settings.dart';
import 'package:app_example/services/app_settings_service.dart';
import 'package:app_example/ui/widgets/section_header.dart';
import 'package:flutter/material.dart';

/// Dedicated page that clearly demonstrates every stream feature:
///
/// 1. Streams fire immediately when a setter is called (optimistic update).
/// 2. Streams fire from storage on startup and after refresh() — StreamBuilders
///    show persisted values without any manual setState.
/// 3. Custom stream name via @PrefEntry(streamer: 'on{{Name}}Updated').
/// 4. Standard stream name from the preset's default '{{name}}Stream'.
/// 5. Stream on a read-only field — readOnly only disables write methods,
///    not the stream. installIdStream still fires on load.
/// 6. removeAll() fires all streams with their default values.
class StreamDemoPage extends StatelessWidget {
  const StreamDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final s = appSettings.regular;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stream Live Demo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'refresh() — reloads from storage and fires streams',
            onPressed: () async {
              await s.refresh();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'refresh() called — all streams received storage values',
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 80),
        children: [
          // ----------------------------------------------------------------
          // 1. Standard stream name from reactive() preset: '{{name}}Stream'
          //    Generated:  Stream<String> get usernameStream
          // ----------------------------------------------------------------
          const SectionHeader('1. usernameStream  (preset default template)'),
          StreamBuilder<String>(
            stream: s.usernameStream,
            builder: (context, snap) => _StreamTile(
              label: 'usernameStream',
              value: snap.data ?? '(no event yet)',
              hasData: snap.hasData,
              onSet: () => s.setUsername('user_${DateTime.now().second}'),
              onRemove: s.removeUsername,
            ),
          ),

          // ----------------------------------------------------------------
          // 2. Custom stream name: @PrefEntry(streamer: 'on{{Name}}Updated')
          //    Generated:  Stream<int> get onLaunchCountUpdated
          // ----------------------------------------------------------------
          const SectionHeader('2. onLaunchCountUpdated  (custom template)'),
          StreamBuilder<int>(
            stream: s.onLaunchCountUpdated,
            builder: (context, snap) => _StreamTile(
              label: 'onLaunchCountUpdated',
              value: snap.data?.toString() ?? '(no event yet)',
              hasData: snap.hasData,
              onSet: () => s.setLaunchCount(s.launchCount + 1),
              onRemove: s.removeLaunchCount,
              setLabel: 'Increment',
            ),
          ),

          // ----------------------------------------------------------------
          // 3. Bool stream — isFirstLaunchStream
          // ----------------------------------------------------------------
          const SectionHeader('3. isFirstLaunchStream  (bool)'),
          StreamBuilder<bool>(
            stream: s.isFirstLaunchStream,
            builder: (context, snap) => _StreamTile(
              label: 'isFirstLaunchStream',
              value: snap.data?.toString() ?? '(no event yet)',
              hasData: snap.hasData,
              onSet: () => s.setIsFirstLaunch(!s.isFirstLaunch),
              onRemove: s.removeIsFirstLaunch,
              setLabel: 'Toggle',
            ),
          ),

          // ----------------------------------------------------------------
          // 4. Nullable stream — lastNotificationIdStream
          // ----------------------------------------------------------------
          const SectionHeader('4. lastNotificationIdStream  (int?)'),
          StreamBuilder<int?>(
            stream: s.lastNotificationIdStream,
            builder: (context, snap) => _StreamTile(
              label: 'lastNotificationIdStream',
              value: snap.data?.toString() ?? 'null',
              hasData: snap.hasData,
              onSet: () => s.setLastNotificationId(DateTime.now().millisecond),
              onRemove: s.removeLastNotificationId,
            ),
          ),

          // ----------------------------------------------------------------
          // 5. Enum stream — languageStream
          // ----------------------------------------------------------------
          const SectionHeader('5. languageStream  (enum)'),
          StreamBuilder<AppLanguage>(
            stream: s.languageStream,
            builder: (context, snap) => _StreamTile(
              label: 'languageStream',
              value: snap.data?.name ?? '(no event yet)',
              hasData: snap.hasData,
              onSet: () {
                const values = AppLanguage.values;
                final next = values[(values.indexOf(s.language) + 1) % values.length];
                s.setLanguage(next);
              },
              onRemove: s.removeLanguage,
              setLabel: 'Cycle',
            ),
          ),

          // ----------------------------------------------------------------
          // 6. Read-only field stream — installIdStream
          //    @PrefEntry(readOnly: true) suppresses setter/remover but NOT
          //    the stream. The stream fires from _load() on startup/refresh.
          // ----------------------------------------------------------------
          const SectionHeader('6. installIdStream  (readOnly field)'),
          StreamBuilder<String>(
            stream: s.installIdStream,
            builder: (context, snap) => ListTile(
              leading: Icon(
                snap.hasData ? Icons.circle : Icons.circle_outlined,
                color: snap.hasData ? Colors.green : Theme.of(context).colorScheme.outline,
                size: 12,
              ),
              title: const Text('installIdStream'),
              subtitle: Text(snap.data ?? '(no event yet)'),
              trailing: const Chip(label: Text('read-only')),
            ),
          ),

          // ----------------------------------------------------------------
          // 7. removeAll() fires all streams with their default values
          // ----------------------------------------------------------------
          const SectionHeader('7. removeAll — fires all streams with defaults'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: FilledButton.tonal(
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.errorContainer,
                foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
              ),
              onPressed: () async {
                await s.removeAll();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'removeAll() — storage cleared, streams fired with defaults',
                      ),
                    ),
                  );
                }
              },
              child: const Text('removeAll() — reset & fire all streams'),
            ),
          ),
        ],
      ),
    );
  }
}

/// Reusable tile that shows a stream's live value and provides
/// set / reset buttons to trigger stream events.
class _StreamTile extends StatelessWidget {
  final String label;
  final String value;
  final bool hasData;
  final VoidCallback onSet;
  final VoidCallback onRemove;
  final String setLabel;

  const _StreamTile({
    required this.label,
    required this.value,
    required this.hasData,
    required this.onSet,
    required this.onRemove,
    this.setLabel = 'Set',
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        hasData ? Icons.circle : Icons.circle_outlined,
        color: hasData ? Colors.green : Theme.of(context).colorScheme.outline,
        size: 12,
      ),
      title: Text(label),
      subtitle: Text(
        value,
        style: TextStyle(
          fontFamily: 'monospace',
          color: hasData
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.outline,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton(onPressed: onSet, child: Text(setLabel)),
          TextButton(onPressed: onRemove, child: const Text('Reset')),
        ],
      ),
    );
  }
}
