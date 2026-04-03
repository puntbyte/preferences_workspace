// Golden test for the `.minimal()` preset.
//
// Verifies that the generator emits only synchronous getters, setters, and
// removers — no async variants, no streams, no `refresh`, no `removeAll`.
// This is the tightest possible API surface and the most important preset to
// guard against accidental method bloat.

import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:dart_style/dart_style.dart';
import 'package:preferences_annotation/preferences_annotation.dart';
import 'package:preferences_generator/src/preferences_generator.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';

const _inputSchema = r'''
library test;

import 'package:preferences_annotation/preferences_annotation.dart';

part 'cli_config.prefs.dart';

@PrefsModule.minimal()
abstract class CliConfig with _$CliConfig {
  factory CliConfig(PrefsAdapter adapter) = _CliConfig;

  CliConfig._({
    String serverUrl = 'https://api.example.com',
    int timeout = 30,
    bool verbose = false,
  });
}
''';

const _expected = r'''
// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: type=lint, prefer_const_constructors
// ignore_for_file: unused_import, prefer_relative_imports

part of 'cli_config.dart';

// **************************************************************************
// PreferenceGenerator
// **************************************************************************

class _CliConfigKeys {
  static const serverUrl = 'serverUrl';
  static const timeout = 'timeout';
  static const verbose = 'verbose';
}

mixin _$CliConfig {
  PrefsAdapter get _adapter;
  String get _serverUrl;
  set _serverUrl(String value);
  int get _timeout;
  set _timeout(int value);
  bool get _verbose;
  set _verbose(bool value);

  String get serverUrl => _serverUrl;
  int get timeout => _timeout;
  bool get verbose => _verbose;

  Future<void> _load() async {
    if (_isLoaded) return;
    bool hasChanged = false;
    final rawServerUrl = await _adapter.get<String>(_CliConfigKeys.serverUrl);
    final newServerUrl = rawServerUrl == null ? 'https://api.example.com' : rawServerUrl;
    if (_serverUrl != newServerUrl) { _serverUrl = newServerUrl; hasChanged = true; }
    final rawTimeout = await _adapter.get<int>(_CliConfigKeys.timeout);
    final newTimeout = rawTimeout == null ? 30 : rawTimeout;
    if (_timeout != newTimeout) { _timeout = newTimeout; hasChanged = true; }
    final rawVerbose = await _adapter.get<bool>(_CliConfigKeys.verbose);
    final newVerbose = rawVerbose == null ? false : rawVerbose;
    if (_verbose != newVerbose) { _verbose = newVerbose; hasChanged = true; }
    _isLoaded = true;
  }

  void setServerUrl(String value) {
    if (_serverUrl != value) {
      _serverUrl = value;
      Future(() async { try { await _adapter.set<String>(_CliConfigKeys.serverUrl, value); } catch (e, st) { // ignore: write failure — no onWriteError callback provided. } });
    }
  }

  void removeServerUrl() {
    if (_serverUrl != 'https://api.example.com') {
      _serverUrl = 'https://api.example.com';
      Future(() async { try { await _adapter.remove(_CliConfigKeys.serverUrl); } catch (e, st) { // ignore: write failure — no onWriteError callback provided. } });
    }
  }

  void setTimeout(int value) {
    if (_timeout != value) {
      _timeout = value;
      Future(() async { try { await _adapter.set<int>(_CliConfigKeys.timeout, value); } catch (e, st) { // ignore: write failure — no onWriteError callback provided. } });
    }
  }

  void removeTimeout() {
    if (_timeout != 30) {
      _timeout = 30;
      Future(() async { try { await _adapter.remove(_CliConfigKeys.timeout); } catch (e, st) { // ignore: write failure — no onWriteError callback provided. } });
    }
  }

  void setVerbose(bool value) {
    if (_verbose != value) {
      _verbose = value;
      Future(() async { try { await _adapter.set<bool>(_CliConfigKeys.verbose, value); } catch (e, st) { // ignore: write failure — no onWriteError callback provided. } });
    }
  }

  void removeVerbose() {
    if (_verbose != false) {
      _verbose = false;
      Future(() async { try { await _adapter.remove(_CliConfigKeys.verbose); } catch (e, st) { // ignore: write failure — no onWriteError callback provided. } });
    }
  }
}

class _CliConfig extends CliConfig with _$CliConfig {
  @override
  final PrefsAdapter _adapter;
  bool _isLoaded = false;
  @override
  late String _serverUrl;
  @override
  late int _timeout;
  @override
  late bool _verbose;

  _CliConfig(this._adapter)
      : super._(
            serverUrl: 'https://api.example.com', timeout: 30, verbose: false) {
    _serverUrl = 'https://api.example.com';
    _timeout = 30;
    _verbose = false;
    _load();
  }
}
''';

String _format(String source) =>
    DartFormatter(languageVersion: DartFormatter.latestLanguageVersion)
        .format(source);

void main() {
  group('golden: minimal preset', () {
    test('full generator output matches snapshot', () async {
      final library = await resolveSource(
        _inputSchema,
        (resolver) => resolver.findLibraryByName('test'),
      );

      final reader = LibraryReader(library!);
      const generator = PreferenceGenerator(BuilderOptions({}));
      final output = StringBuffer();

      for (final annotatedElement in reader.annotatedWith(
        const TypeChecker.fromRuntime(PrefsModule),
      )) {
        final result = await generator.generateForAnnotatedElement(
          annotatedElement.element,
          annotatedElement.annotation,
          FakeBuildStep(),
        );
        output.writeln(result);
      }

      expect(_format(output.toString()), equals(_format(_expected)));
    });

    test('output contains no async getter methods', () async {
      final library = await resolveSource(
        _inputSchema,
        (resolver) => resolver.findLibraryByName('test'),
      );
      final reader = LibraryReader(library!);
      const generator = PreferenceGenerator(BuilderOptions.empty);
      final output = StringBuffer();
      for (final annotatedElement in reader.annotatedWith(
        const TypeChecker.fromRuntime(PrefsModule),
      )) {
        output.writeln(await generator.generateForAnnotatedElement(
          annotatedElement.element,
          annotatedElement.annotation,
          FakeBuildStep(),
        ));
      }

      final code = output.toString();
      expect(code, isNot(contains('Async()')));
      expect(code, isNot(contains('Stream<')));
      expect(code, isNot(contains('refresh')));
      expect(code, isNot(contains('removeAll')));
    });

    test('output uses keys class references in all adapter calls', () async {
      final library = await resolveSource(
        _inputSchema,
        (resolver) => resolver.findLibraryByName('test'),
      );
      final reader = LibraryReader(library!);
      const generator = PreferenceGenerator(BuilderOptions({}));
      final output = StringBuffer();
      for (final annotatedElement in reader.annotatedWith(
        const TypeChecker.fromRuntime(PrefsModule),
      )) {
        output.writeln(await generator.generateForAnnotatedElement(
          annotatedElement.element,
          annotatedElement.annotation,
          FakeBuildStep(),
        ));
      }

      final code = output.toString();
      // Adapter calls must use _CliConfigKeys.x, not a raw string 'x'.
      expect(code, contains('_CliConfigKeys.serverUrl'));
      expect(code, contains('_CliConfigKeys.timeout'));
      expect(code, contains('_CliConfigKeys.verbose'));
      expect(code, isNot(contains("'serverUrl'")));
      expect(code, isNot(contains("'timeout'")));
      expect(code, isNot(contains("'verbose'")));
    });
  });
}

class FakeBuildStep implements BuildStep {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
