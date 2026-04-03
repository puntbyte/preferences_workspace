import 'dart:async';

import 'package:app_example/preferences/converters/color_converter.dart';
import 'package:app_example/preferences/converters/user_profile_converter.dart';
import 'package:flutter/material.dart';
import 'package:preferences_annotation/preferences_annotation.dart';

part '../generated/preferences/app_settings.prefs.dart';

enum AppLanguage { english, spanish, french }

// onWriteError is wired up here to demonstrate P1 error-handling feature.
@PrefsModule.reactive(onWriteError: AppSettings._onWriteError)
abstract class AppSettings with _$AppSettings, ChangeNotifier {
  factory AppSettings(PrefsAdapter adapter) = _AppSettings;

  AppSettings._();

  /// Called when a synchronous (fire-and-forget) storage write fails.
  /// Demonstrates the onWriteError P1 feature.
  static void _onWriteError(Object error, StackTrace st) {
    debugPrint('[AppSettings] Write failed: $error');
  }
}
