import 'dart:async';

import 'package:app_example/preferences/converters/color_converter.dart';
import 'package:app_example/preferences/converters/user_profile_converter.dart';
import 'package:flutter/material.dart';
import 'package:preferences_annotation/preferences_annotation.dart';

part '../generated/preferences/app_settings.prefs.dart';

enum AppLanguage { english, spanish, french }

@PrefsModule.reactive()
abstract class AppSettings with _$AppSettings, ChangeNotifier {
  factory AppSettings(PrefsAdapter adapter) = _AppSettings;

  AppSettings._();
}
