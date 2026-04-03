// Golden test for the `.reactive()` preset.
//
// Runs the full generator pipeline against a fixed schema and diffs the output
// against a known-good snapshot. Any change to the generated code — intentional
// or accidental — will be caught here.
//
// To regenerate the golden after an intentional change:
//   1. Update `_expected` in this file to match the new output.
//   2. Re-run the tests to confirm they pass.

import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:dart_style/dart_style.dart';
import 'package:preferences_annotation/preferences_annotation.dart';
import 'package:preferences_generator/src/preferences_generator.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';

const _inputSchema = r'''
library test;

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:preferences_annotation/preferences_annotation.dart';

part 'settings.prefs.dart';

@PrefsModule.reactive()
abstract class Settings with _$Settings, ChangeNotifier {
  factory Settings(PrefsAdapter adapter) = _Settings;

  Settings._({
    String username = 'guest',
    bool isDarkMode = false,
    int? launchCount,
  });
}
''';

// The expected output after formatting.
// Updating this string IS the correct way to accept an intentional change.
const _expected = r'''
// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: type=lint, prefer_const_constructors
// ignore_for_file: unused_import, prefer_relative_imports

part of 'settings.dart';

// **************************************************************************
// PreferenceGenerator
// **************************************************************************

class _SettingsKeys {
  static const username = 'username';
  static const isDarkMode = 'isDarkMode';
  static const launchCount = 'launchCount';
}

mixin _$Settings {
  PrefsAdapter get _adapter;
  String get _username;
  set _username(String value);
  StreamController<String> get _usernameStreamController;
  bool get _isDarkMode;
  set _isDarkMode(bool value);
  StreamController<bool> get _isDarkModeStreamController;
  int? get _launchCount;
  set _launchCount(int? value);
  StreamController<int?> get _launchCountStreamController;

  String get username => _username;
  bool get isDarkMode => _isDarkMode;
  int? get launchCount => _launchCount;

  Future<void> refresh() async {
    _isLoaded = false;
    await _load();
  }

  Future<void> removeAll() async {
    await _adapter.removeAll();
    _isLoaded = false;
    await _load();
  }

  void dispose() {
    _usernameStreamController.close();
    _isDarkModeStreamController.close();
    _launchCountStreamController.close();
  }

  Future<void> _load() async {
    if (_isLoaded) return;
    bool hasChanged = false;
    final rawUsername = await _adapter.get<String>(_SettingsKeys.username);
    final newUsername = rawUsername == null ? 'guest' : rawUsername;
    if (_username != newUsername) { _username = newUsername; hasChanged = true; }
    final rawIsDarkMode = await _adapter.get<bool>(_SettingsKeys.isDarkMode);
    final newIsDarkMode = rawIsDarkMode == null ? false : rawIsDarkMode;
    if (_isDarkMode != newIsDarkMode) { _isDarkMode = newIsDarkMode; hasChanged = true; }
    final rawLaunchCount = await _adapter.get<int>(_SettingsKeys.launchCount);
    final newLaunchCount = rawLaunchCount == null ? null : rawLaunchCount;
    if (_launchCount != newLaunchCount) { _launchCount = newLaunchCount; hasChanged = true; }
    _isLoaded = true;
    if (hasChanged) { (this as ChangeNotifier).notifyListeners(); }
  }

  void setUsername(String value) {
    if (_username != value) {
      _username = value;
      Future(() async { try { await _adapter.set<String>(_SettingsKeys.username, value); } catch (e, st) { // ignore: write failure — no onWriteError callback provided. } });
      _usernameStreamController.add(value);
      (this as ChangeNotifier).notifyListeners();
    }
  }

  void removeUsername() {
    if (_username != 'guest') {
      _username = 'guest';
      Future(() async { try { await _adapter.remove(_SettingsKeys.username); } catch (e, st) { // ignore: write failure — no onWriteError callback provided. } });
      _usernameStreamController.add('guest');
      (this as ChangeNotifier).notifyListeners();
    }
  }

  Stream<String> get usernameStream => _usernameStreamController.stream;

  void setIsDarkMode(bool value) {
    if (_isDarkMode != value) {
      _isDarkMode = value;
      Future(() async { try { await _adapter.set<bool>(_SettingsKeys.isDarkMode, value); } catch (e, st) { // ignore: write failure — no onWriteError callback provided. } });
      _isDarkModeStreamController.add(value);
      (this as ChangeNotifier).notifyListeners();
    }
  }

  void removeIsDarkMode() {
    if (_isDarkMode != false) {
      _isDarkMode = false;
      Future(() async { try { await _adapter.remove(_SettingsKeys.isDarkMode); } catch (e, st) { // ignore: write failure — no onWriteError callback provided. } });
      _isDarkModeStreamController.add(false);
      (this as ChangeNotifier).notifyListeners();
    }
  }

  Stream<bool> get isDarkModeStream => _isDarkModeStreamController.stream;

  void setLaunchCount(int value) {
    if (_launchCount != value) {
      _launchCount = value;
      Future(() async { try { await _adapter.set<int>(_SettingsKeys.launchCount, value); } catch (e, st) { // ignore: write failure — no onWriteError callback provided. } });
      _launchCountStreamController.add(value);
      (this as ChangeNotifier).notifyListeners();
    }
  }

  void removeLaunchCount() {
    if (_launchCount != null) {
      _launchCount = null;
      Future(() async { try { await _adapter.remove(_SettingsKeys.launchCount); } catch (e, st) { // ignore: write failure — no onWriteError callback provided. } });
      _launchCountStreamController.add(null);
      (this as ChangeNotifier).notifyListeners();
    }
  }

  Stream<int?> get launchCountStream => _launchCountStreamController.stream;
}

class _Settings extends Settings with _$Settings {
  @override
  final PrefsAdapter _adapter;
  bool _isLoaded = false;
  @override
  late String _username;
  @override
  late bool _isDarkMode;
  @override
  int? _launchCount;
  @override
  final StreamController<String> _usernameStreamController =
      StreamController<String>.broadcast();
  @override
  final StreamController<bool> _isDarkModeStreamController =
      StreamController<bool>.broadcast();
  @override
  final StreamController<int?> _launchCountStreamController =
      StreamController<int?>.broadcast();

  _Settings(this._adapter)
      : super._(username: 'guest', isDarkMode: false) {
    _username = 'guest';
    _isDarkMode = false;
    _launchCount = null;
    _usernameStreamController.add(_username);
    _isDarkModeStreamController.add(_isDarkMode);
    _load();
  }
}
''';

String _format(String source) =>
    DartFormatter(languageVersion: DartFormatter.latestLanguageVersion)
        .format(source);

void main() {
  group('golden: reactive preset', () {
    test('full generator output matches snapshot', () async {
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
        final result = await generator.generateForAnnotatedElement(
          annotatedElement.element,
          annotatedElement.annotation,
          FakeBuildStep(),
        );
        output.writeln(result);
      }

      expect(_format(output.toString()), equals(_format(_expected)));
    });
  });
}

/// Minimal stub to satisfy [GeneratorForAnnotation.generateForAnnotatedElement].
class FakeBuildStep implements BuildStep {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
