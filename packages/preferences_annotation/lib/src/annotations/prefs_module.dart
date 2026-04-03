import 'package:meta/meta.dart';
import 'package:preferences_annotation/src/config/key_case.dart';

/// Marks an abstract class as a preference module and configures the API that
/// the code generator will produce.
///
/// ## Quick Start: Choose a Preset
///
/// The easiest way to configure a module is to use one of the built-in presets.
/// Each preset is a named constructor that pre-fills sensible method name
/// templates for a common storage backend pattern.
///
/// | Preset            | Best For                             | Example methods (`username`) |
/// |-------------------|--------------------------------------|------------------------------|
/// | [.dictionary()]   | `shared_preferences` (recommended)  | `getUsername()`, `setUsername()` async, `removeUsername()` async |
/// | [.reactive()]     | Reactive UIs with `ChangeNotifier`  | `username`, `setUsername()`, `usernameStream` |
/// | [.syncOnly()]     | Fully synchronous stores (Hive)     | `getUsername()`, `putUsername()`, `deleteUsername()` |
/// | [.syncFirst()]    | Both sync + async methods           | `username`, `setUsername()`, `usernameAsync()` |
/// | [.minimal()]      | CLI tools, simple scripts           | `username`, `setUsername()`, `removeUsername()` |
/// | [.exhaustive()]   | Complete API surface (all methods)  | `getUsernameSync`, `setUsernameSync`, `getUsernameAsync`, ... |
///
/// ## Method Name Templates
///
/// All per-entry method name parameters accept a template string with two
/// substitution tokens:
///
/// - `{{name}}` — the camelCase field name (e.g., `isFirstLaunch`)
/// - `{{Name}}` — the field name with the first letter capitalised
///   (e.g., `IsFirstLaunch`)
///
/// A `null` value disables that method across the entire module.
///
/// ### Example: a custom module configuration
///
/// ```dart
/// @PrefsModule(
///   notifiable: true,
///   getter: '{{name}}',
///   setter: 'update{{Name}}',
///   remover: 'reset{{Name}}',
///   asyncSetter: 'update{{Name}}Async',
///   streamer: 'on{{Name}}Changed',
///   removeAll: 'resetAll',
///   refresh: 'reload',
/// )
/// abstract class AppSettings with _$AppSettings, ChangeNotifier {
///   factory AppSettings(PrefsAdapter adapter) = _AppSettings;
///   AppSettings._({ String username = 'guest' });
/// }
/// ```
@immutable
class PrefsModule {
  /// Whether changes to this module should call `notifyListeners()`.
  ///
  /// Only meaningful when the module class mixes in `ChangeNotifier`.
  /// Defaults to `false`. Can be overridden per-entry with
  /// `@PrefEntry(notifiable: ...)`.
  final bool notifiable;

  /// The casing convention to apply to all generated storage keys.
  ///
  /// Takes precedence over any `key_case` value in `build.yaml`. An explicit
  /// `@PrefEntry(key: ...)` always takes precedence over this value.
  ///
  /// ```dart
  /// @PrefsModule(keyCase: KeyCase.snake) // `launchCount` → `'launch_count'`
  /// ```
  final KeyCase? keyCase;

  /// A reference to a static error-handling function that is called when a
  /// **synchronous** setter's background write fails.
  ///
  /// Synchronous setters use a fire-and-forget write pattern. By default, any
  /// write errors are silently swallowed. Providing this callback gives you
  /// visibility into those failures.
  ///
  /// The function must have the signature `void Function(Object, StackTrace)`.
  ///
  /// ```dart
  /// @PrefsModule.reactive(onWriteError: AppSettings._onWriteError)
  /// abstract class AppSettings with _$AppSettings, ChangeNotifier {
  ///   static void _onWriteError(Object error, StackTrace st) {
  ///     debugPrint('Pref write failed: $error');
  ///   }
  ///   ...
  /// }
  /// ```
  final void Function(Object error, StackTrace)? onWriteError;

  // ---------------------------------------------------------------------------
  // Per-entry method name templates (null = disabled across the module)
  // ---------------------------------------------------------------------------

  /// Template for synchronous getters. `null` disables sync getters.
  ///
  /// Example: `'{{name}}'` → `bool get isFirstLaunch`
  final String? getter;

  /// Template for synchronous setters. `null` disables sync setters.
  ///
  /// Example: `'set{{Name}}'` → `void setIsFirstLaunch(bool value)`
  final String? setter;

  /// Template for synchronous removers. `null` disables sync removers.
  ///
  /// Example: `'remove{{Name}}'` → `void removeIsFirstLaunch()`
  final String? remover;

  /// Template for asynchronous getters. `null` disables async getters.
  ///
  /// Example: `'{{name}}Async'` → `Future<bool> isFirstLaunchAsync()`
  final String? asyncGetter;

  /// Template for asynchronous setters. `null` disables async setters.
  ///
  /// Example: `'set{{Name}}Async'` → `Future<void> setIsFirstLaunchAsync(bool value)`
  final String? asyncSetter;

  /// Template for asynchronous removers. `null` disables async removers.
  ///
  /// Example: `'remove{{Name}}Async'` → `Future<void> removeIsFirstLaunchAsync()`
  final String? asyncRemover;

  /// Template for stream getters. `null` disables stream generation.
  ///
  /// Example: `'{{name}}Stream'` → `Stream<bool> get isFirstLaunchStream`
  final String? streamer;

  // ---------------------------------------------------------------------------
  // Module-level method names (no template substitution — these are literal names)
  // ---------------------------------------------------------------------------

  /// The name of the generated `removeAll` method. `null` disables it.
  ///
  /// Example: `'removeAll'` → `Future<void> removeAll()`
  final String? removeAll;

  /// The name of the generated `refresh` method. `null` disables it.
  ///
  /// Example: `'refresh'` → `Future<void> refresh()`
  final String? refresh;

  // ---------------------------------------------------------------------------
  // Main constructor
  // ---------------------------------------------------------------------------

  /// The main constructor for defining a fully custom preference module.
  ///
  /// For most use cases, prefer a named preset constructor.
  const PrefsModule({
    this.notifiable = false,
    this.keyCase,
    this.onWriteError,
    this.getter = '{{name}}',
    this.setter = 'set{{Name}}',
    this.remover = 'remove{{Name}}',
    this.asyncGetter,
    this.asyncSetter,
    this.asyncRemover,
    this.streamer,
    this.removeAll = 'removeAll',
    this.refresh = 'refresh',
  });

  // ---------------------------------------------------------------------------
  // Presets
  // ---------------------------------------------------------------------------

  /// **Recommended default.** For `shared_preferences` and similar
  /// asynchronous key-value stores.
  ///
  /// Generates: synchronous getters, asynchronous setters and removers.
  /// Streaming is disabled by default.
  ///
  /// Generated methods for a field named `username`:
  /// - Getter: `getUsername()` (sync)
  /// - Setter: `setUsername(value)` (async)
  /// - Remover: `removeUsername()` (async)
  const PrefsModule.dictionary({
    bool? notifiable,
    KeyCase? keyCase,
    void Function(Object, StackTrace)? onWriteError,
    String? getter,
    String? setter,
    String? remover,
    String? asyncGetter,
    String? asyncSetter,
    String? asyncRemover,
    String? streamer,
    String? removeAll,
    String? refresh,
  }) : this(
         notifiable: notifiable ?? false,
         keyCase: keyCase,
         onWriteError: onWriteError,
         getter: getter ?? 'get{{Name}}',
         setter: setter,
         remover: remover,
         asyncGetter: asyncGetter,
         asyncSetter: asyncSetter ?? 'set{{Name}}',
         asyncRemover: asyncRemover ?? 'remove{{Name}}',
         streamer: streamer,
         removeAll: removeAll ?? 'clear',
         refresh: refresh,
       );

  /// For fully synchronous storage backends such as Hive or GetStorage.
  ///
  /// Generates: synchronous getters, setters, and removers. All async
  /// methods and streaming are disabled.
  ///
  /// Generated methods for a field named `username`:
  /// - Getter: `getUsername()` (sync)
  /// - Setter: `putUsername(value)` (sync)
  /// - Remover: `deleteUsername()` (sync)
  const PrefsModule.syncOnly({
    bool? notifiable,
    KeyCase? keyCase,
    void Function(Object, StackTrace)? onWriteError,
    String? getter,
    String? setter,
    String? remover,
    String? asyncGetter,
    String? asyncSetter,
    String? asyncRemover,
    String? streamer,
    String? removeAll,
    String? refresh,
  }) : this(
         notifiable: notifiable ?? false,
         keyCase: keyCase,
         onWriteError: onWriteError,
         getter: getter ?? 'get{{Name}}',
         setter: setter ?? 'put{{Name}}',
         remover: remover ?? 'delete{{Name}}',
         asyncGetter: asyncGetter,
         asyncSetter: asyncSetter,
         asyncRemover: asyncRemover,
         streamer: streamer,
         removeAll: removeAll ?? 'clear',
         refresh: refresh,
       );

  /// For reactive UIs using `Stream`s and `ChangeNotifier`.
  ///
  /// Enables `notifiable` by default. Generates sync getters and setters,
  /// plus a stream for every entry.
  ///
  /// Generated methods for a field named `username`:
  /// - Getter: `username` (sync, no prefix)
  /// - Setter: `setUsername(value)` (sync)
  /// - Remover: `removeUsername()` (sync)
  /// - Stream: `usernameStream`
  const PrefsModule.reactive({
    bool? notifiable,
    KeyCase? keyCase,
    void Function(Object, StackTrace)? onWriteError,
    String? getter,
    String? setter,
    String? remover,
    String? asyncGetter,
    String? asyncSetter,
    String? asyncRemover,
    String? streamer,
    String? removeAll,
    String? refresh,
  }) : this(
         notifiable: notifiable ?? true,
         keyCase: keyCase,
         onWriteError: onWriteError,
         getter: getter ?? '{{name}}',
         setter: setter ?? 'set{{Name}}',
         remover: remover ?? 'remove{{Name}}',
         asyncGetter: asyncGetter,
         asyncSetter: asyncSetter,
         asyncRemover: asyncRemover,
         streamer: streamer ?? '{{name}}Stream',
         removeAll: removeAll ?? 'removeAll',
         refresh: refresh ?? 'refresh',
       );

  /// Sync-first: synchronous methods are primary, with async counterparts also
  /// available. Good for mixed-latency storage adapters.
  ///
  /// Generated methods for a field named `username`:
  /// - Getter: `username` (sync) and `usernameAsync()` (async)
  /// - Setter: `setUsername(value)` (sync) and `setUsernameAsync(value)` (async)
  const PrefsModule.syncFirst({
    bool? notifiable,
    KeyCase? keyCase,
    void Function(Object, StackTrace)? onWriteError,
    String? getter,
    String? setter,
    String? remover,
    String? asyncGetter,
    String? asyncSetter,
    String? asyncRemover,
    String? streamer,
    String? removeAll,
    String? refresh,
  }) : this(
         notifiable: notifiable ?? false,
         keyCase: keyCase,
         onWriteError: onWriteError,
         getter: getter ?? '{{name}}',
         setter: setter ?? 'set{{Name}}',
         remover: remover ?? 'remove{{Name}}',
         asyncGetter: asyncGetter ?? '{{name}}Async',
         asyncSetter: asyncSetter ?? 'set{{Name}}Async',
         asyncRemover: asyncRemover ?? 'remove{{Name}}Async',
         streamer: streamer,
         removeAll: removeAll ?? 'removeAll',
         refresh: refresh ?? 'refresh',
       );

  /// Minimal: synchronous getters, setters, and removers only — no async
  /// variants, no streams, no module-level methods.
  ///
  /// Ideal for CLI tools, scripts, or any context where simplicity is more
  /// important than reactivity.
  ///
  /// Generated methods for a field named `username`:
  /// - Getter: `username` (sync)
  /// - Setter: `setUsername(value)` (sync)
  /// - Remover: `removeUsername()` (sync)
  const PrefsModule.minimal({
    bool? notifiable,
    KeyCase? keyCase,
    void Function(Object, StackTrace)? onWriteError,
    String? getter,
    String? setter,
    String? remover,
  }) : this(
         notifiable: notifiable ?? false,
         keyCase: keyCase,
         onWriteError: onWriteError,
         getter: getter ?? '{{name}}',
         setter: setter ?? 'set{{Name}}',
         remover: remover ?? 'remove{{Name}}',
         asyncGetter: null,
         asyncSetter: null,
         asyncRemover: null,
         streamer: null,
         removeAll: null,
         refresh: null,
       );

  /// Read-only: only getter methods are generated. No writes, no streams.
  ///
  /// Useful for preference modules that are populated externally or by a
  /// separate write-only module.
  const PrefsModule.readOnly({
    bool? notifiable,
    KeyCase? keyCase,
    String? getter,
    String? asyncGetter,
  }) : this(
         notifiable: notifiable ?? false,
         keyCase: keyCase,
         getter: getter ?? '{{name}}',
         setter: null,
         remover: null,
         asyncGetter: asyncGetter,
         asyncSetter: null,
         asyncRemover: null,
         streamer: null,
         removeAll: null,
         refresh: null,
       );

  /// Exhaustive: generates every possible method variant with consistent,
  /// predictable naming conventions.
  ///
  /// Generates all sync, async, and stream methods. Useful for verifying the
  /// complete output of the generator and for backends that support all
  /// operation modes.
  ///
  /// Generated methods for a field named `username`:
  /// - `getUsernameSync`, `setUsernameSync`, `removeUsernameSync`
  /// - `getUsernameAsync`, `setUsernameAsync`, `removeUsernameAsync`
  /// - `watchUsernameStream`
  ///
  /// > **Note:** Formerly called `.testing()`. The old name is preserved as a
  /// > deprecated alias below.
  const PrefsModule.exhaustive({
    bool? notifiable,
    KeyCase? keyCase,
    void Function(Object, StackTrace)? onWriteError,
    String? getter,
    String? setter,
    String? remover,
    String? asyncGetter,
    String? asyncSetter,
    String? asyncRemover,
    String? streamer,
    String? removeAll,
    String? refresh,
  }) : this(
         notifiable: notifiable ?? true,
         keyCase: keyCase,
         onWriteError: onWriteError,
         getter: getter ?? 'get{{Name}}Sync',
         setter: setter ?? 'set{{Name}}Sync',
         remover: remover ?? 'remove{{Name}}Sync',
         asyncGetter: asyncGetter ?? 'get{{Name}}Async',
         asyncSetter: asyncSetter ?? 'set{{Name}}Async',
         asyncRemover: asyncRemover ?? 'remove{{Name}}Async',
         streamer: streamer ?? 'watch{{Name}}Stream',
         removeAll: removeAll ?? 'removeAll',
         refresh: refresh ?? 'refresh',
       );

  /// Disabled: generates no methods at all.
  ///
  /// A useful starting point for building a completely custom configuration
  /// from scratch by overriding only the methods you want.
  const PrefsModule.disabled({
    bool? notifiable,
    KeyCase? keyCase,
  }) : this(
         notifiable: notifiable ?? false,
         keyCase: keyCase,
         getter: null,
         setter: null,
         remover: null,
         asyncGetter: null,
         asyncSetter: null,
         asyncRemover: null,
         streamer: null,
         removeAll: null,
         refresh: null,
       );
}
