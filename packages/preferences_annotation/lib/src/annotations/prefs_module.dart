import 'package:meta/meta.dart';
import 'package:preferences_annotation/preferences_annotation.dart';

@immutable
class PrefsModule {
  final bool notifiable;
  final KeyCase? keyCase;

  // --- Per-Entry Method Configurations ---
  final AffixConfig getter;
  final AffixConfig setter;
  final AffixConfig remover;

  final AffixConfig asyncGetter;
  final AffixConfig asyncSetter;
  final AffixConfig asyncRemover;

  final AffixConfig streamer;

  // --- Module-Level Method Configurations ---
  final NamedConfig removeAll;
  final NamedConfig refresh;

  // -------------------------
  // Shared default constants
  // -------------------------
  static const AffixConfig _affixDefault = AffixConfig();
  static const AffixConfig _affixGet = AffixConfig(prefix: 'get');
  static const AffixConfig _affixSet = AffixConfig(prefix: 'set');
  static const AffixConfig _affixRemove = AffixConfig(prefix: 'remove');
  static const AffixConfig _affixPut = AffixConfig(prefix: 'put');

  static const AffixConfig _asyncGetSuffix = AffixConfig(suffix: 'Async');
  static const AffixConfig _asyncSetPrefixSuffix = AffixConfig(prefix: 'set', suffix: 'Async');
  static const AffixConfig _asyncRemovePrefixSuffix = AffixConfig(
    prefix: 'remove',
    suffix: 'Async',
  );

  static const AffixConfig _streamDisabled = AffixConfig(enabled: false);
  static const AffixConfig _streamDefault = AffixConfig(suffix: 'Stream');

  static const NamedConfig _removeAllClear = NamedConfig(name: 'clear');
  static const NamedConfig _removeAllDefault = NamedConfig(name: 'removeAll');
  static const NamedConfig _refreshDefault = NamedConfig(name: 'refresh');
  static const NamedConfig _refreshDisabled = NamedConfig(enabled: false);

  /// The main constructor for defining a custom preference module behavior.
  const PrefsModule({
    this.notifiable = false,
    this.keyCase,

    this.getter = _affixDefault,
    this.setter = _affixSet,
    this.remover = _affixRemove,

    this.asyncGetter = _asyncGetSuffix,
    this.asyncSetter = _asyncSetPrefixSuffix,
    this.asyncRemover = _asyncRemovePrefixSuffix,

    this.streamer = const AffixConfig(enabled: false, suffix: 'Stream'),

    this.removeAll = _removeAllDefault,
    this.refresh = _refreshDefault,
  });

  // -----------------------------------------------------------------------
  // Presets — all presets accept optional overrides so callers can customize
  // any single configuration while keeping the rest of the preset defaults.
  // -----------------------------------------------------------------------

  /// A preset for key-value stores like `shared_preferences`.
  /// Defaults: sync getters + async setters/removers, streaming disabled.
  const PrefsModule.dictionary({
    bool? notifiable,
    KeyCase? keyCase,

    AffixConfig? getter,
    AffixConfig? setter,
    AffixConfig? remover,

    AffixConfig? asyncGetter,
    AffixConfig? asyncSetter,
    AffixConfig? asyncRemover,

    AffixConfig? streamer,

    NamedConfig? removeAll,
    NamedConfig? refresh,
  }) : this(
         notifiable: notifiable ?? false,
         keyCase: keyCase,
         getter: getter ?? _affixGet,
         setter: setter ?? const AffixConfig(enabled: false),
         remover: remover ?? const AffixConfig(enabled: false),
         asyncGetter: asyncGetter ?? const AffixConfig(enabled: false),
         asyncSetter: asyncSetter ?? _affixSet,
         asyncRemover: asyncRemover ?? _affixRemove,
         streamer: streamer ?? _streamDisabled,
         removeAll: removeAll ?? _removeAllClear,
         refresh: refresh ?? _refreshDisabled,
       );

  /// A preset for fully synchronous backends like Hive or in-memory maps.
  /// Defaults: sync getter/setter/remover; all async disabled.
  const PrefsModule.syncOnly({
    bool? notifiable,
    KeyCase? keyCase,

    AffixConfig? getter,
    AffixConfig? setter,
    AffixConfig? remover,

    AffixConfig? asyncGetter,
    AffixConfig? asyncSetter,
    AffixConfig? asyncRemover,

    AffixConfig? streamer,

    NamedConfig? removeAll,
    NamedConfig? refresh,
  }) : this(
         notifiable: notifiable ?? false,
         keyCase: keyCase,
         getter: getter ?? _affixGet,
         setter: setter ?? _affixPut,
         remover: remover ?? const AffixConfig(prefix: 'delete'),
         asyncGetter: asyncGetter ?? const AffixConfig(enabled: false),
         asyncSetter: asyncSetter ?? const AffixConfig(enabled: false),
         asyncRemover: asyncRemover ?? const AffixConfig(enabled: false),
         streamer: streamer ?? _streamDisabled,
         removeAll: removeAll ?? _removeAllClear,
         refresh: refresh ?? _refreshDisabled,
       );

  /// Sync-first preset: prefer sync methods but keep async counterparts available.
  const PrefsModule.syncFirst({
    bool? notifiable,
    KeyCase? keyCase,

    AffixConfig? getter,
    AffixConfig? setter,
    AffixConfig? remover,

    AffixConfig? asyncGetter,
    AffixConfig? asyncSetter,
    AffixConfig? asyncRemover,

    AffixConfig? streamer,

    NamedConfig? removeAll,
    NamedConfig? refresh,
  }) : this(
         notifiable: notifiable ?? false,
         keyCase: keyCase,
         getter: getter ?? _affixDefault,
         setter: setter ?? _affixSet,
         remover: remover ?? _affixRemove,
         asyncGetter: asyncGetter ?? _asyncGetSuffix,
         asyncSetter: asyncSetter ?? _asyncSetPrefixSuffix,
         asyncRemover: asyncRemover ?? _asyncRemovePrefixSuffix,
         streamer: streamer ?? _streamDisabled,
         removeAll: removeAll ?? _removeAllDefault,
         refresh: refresh ?? _refreshDefault,
       );

  /// A preset for reactive, stream-first data sources. Enables streaming and
  /// ChangeNotifier compatibility by default.
  const PrefsModule.reactive({
    bool? notifiable,
    KeyCase? keyCase,

    AffixConfig? getter,
    AffixConfig? setter,
    AffixConfig? remover,

    AffixConfig? asyncGetter,
    AffixConfig? asyncSetter,
    AffixConfig? asyncRemover,

    AffixConfig? streamer,

    NamedConfig? removeAll,
    NamedConfig? refresh,
  }) : this(
         notifiable: notifiable ?? true,
         keyCase: keyCase,
         getter: getter ?? _affixDefault,
         setter: setter ?? _affixSet,
         remover: remover ?? _affixRemove,
         asyncGetter: asyncGetter ?? _asyncGetSuffix,
         asyncSetter: asyncSetter ?? _asyncSetPrefixSuffix,
         asyncRemover: asyncRemover ?? _asyncRemovePrefixSuffix,
         streamer: streamer ?? _streamDefault,
         removeAll: removeAll ?? _removeAllDefault,
         refresh: refresh ?? _refreshDefault,
       );

  /// All methods enabled (feature-complete backends).
  const PrefsModule.allEnabled({
    bool? notifiable,
    KeyCase? keyCase,

    AffixConfig? getter,
    AffixConfig? setter,
    AffixConfig? remover,

    AffixConfig? asyncGetter,
    AffixConfig? asyncSetter,
    AffixConfig? asyncRemover,

    AffixConfig? streamer,

    NamedConfig? removeAll,
    NamedConfig? refresh,
  }) : this(
         notifiable: notifiable ?? true,
         keyCase: keyCase,
         getter: getter ?? _affixDefault,
         setter: setter ?? _affixDefault,
         remover: remover ?? _affixDefault,
         asyncGetter: asyncGetter ?? _asyncGetSuffix,
         asyncSetter: asyncSetter ?? _asyncGetSuffix,
         asyncRemover: asyncRemover ?? _asyncGetSuffix,
         streamer: streamer ?? _streamDefault,
         removeAll: removeAll ?? _removeAllDefault,
         refresh: refresh ?? _refreshDefault,
       );

  /// A preset where only getter methods are enabled.
  const PrefsModule.readOnly({
    bool? notifiable,
    KeyCase? keyCase,

    AffixConfig? getter,
    AffixConfig? setter,
    AffixConfig? remover,

    AffixConfig? asyncGetter,
    AffixConfig? asyncSetter,
    AffixConfig? asyncRemover,

    AffixConfig? streamer,

    NamedConfig? removeAll,
    NamedConfig? refresh,
  }) : this(
         notifiable: notifiable ?? false,
         keyCase: keyCase,
         getter: getter ?? _affixDefault,
         setter: setter ?? const AffixConfig(enabled: false),
         remover: remover ?? const AffixConfig(enabled: false),
         asyncGetter: asyncGetter ?? _asyncGetSuffix,
         asyncSetter: asyncSetter ?? const AffixConfig(enabled: false),
         asyncRemover: asyncRemover ?? const AffixConfig(enabled: false),
         streamer: streamer ?? _streamDisabled,
         removeAll: removeAll ?? const NamedConfig(enabled: false),
         refresh: refresh ?? const NamedConfig(enabled: false),
       );

  /// Disabled preset: everything disabled.
  const PrefsModule.disabled({
    bool? notifiable,
    KeyCase? keyCase,

    AffixConfig? getter,
    AffixConfig? setter,
    AffixConfig? remover,

    AffixConfig? asyncGetter,
    AffixConfig? asyncSetter,
    AffixConfig? asyncRemover,

    AffixConfig? streamer,

    NamedConfig? removeAll,
    NamedConfig? refresh,
  }) : this(
         notifiable: notifiable ?? false,
         keyCase: keyCase,
         getter: getter ?? const AffixConfig(enabled: false),
         setter: setter ?? const AffixConfig(enabled: false),
         remover: remover ?? const AffixConfig(enabled: false),
         asyncGetter: asyncGetter ?? const AffixConfig(enabled: false, suffix: 'Async'),
         asyncSetter: asyncSetter ?? const AffixConfig(enabled: false, suffix: 'Async'),
         asyncRemover: asyncRemover ?? const AffixConfig(enabled: false, suffix: 'Async'),
         streamer: streamer ?? const AffixConfig(enabled: false, suffix: 'Stream'),
         removeAll: removeAll ?? const NamedConfig(enabled: false),
         refresh: refresh ?? const NamedConfig(enabled: false),
       );

  /// Testing preset: consistent prefixes/suffixes useful for predictable tests.
  const PrefsModule.testing({
    bool? notifiable,
    KeyCase? keyCase,

    AffixConfig? getter,
    AffixConfig? setter,
    AffixConfig? remover,

    AffixConfig? asyncGetter,
    AffixConfig? asyncSetter,
    AffixConfig? asyncRemover,

    AffixConfig? streamer,

    NamedConfig? removeAll,
    NamedConfig? refresh,
  }) : this(
         notifiable: notifiable ?? true,
         keyCase: keyCase,
         getter: getter ?? const AffixConfig(prefix: 'get', suffix: 'Sync'),
         setter: setter ?? const AffixConfig(prefix: 'set', suffix: 'Sync'),
         remover: remover ?? const AffixConfig(prefix: 'remove', suffix: 'Sync'),
         asyncGetter: asyncGetter ?? const AffixConfig(prefix: 'get', suffix: 'Async'),
         asyncSetter: asyncSetter ?? const AffixConfig(prefix: 'set', suffix: 'Async'),
         asyncRemover: asyncRemover ?? const AffixConfig(prefix: 'remove', suffix: 'Async'),
         streamer: streamer ?? const AffixConfig(prefix: 'watch', suffix: 'Stream'),
         removeAll: removeAll ?? _removeAllDefault,
         refresh: refresh ?? _refreshDefault,
       );
}
