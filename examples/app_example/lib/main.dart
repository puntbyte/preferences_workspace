import 'package:app_example/app.dart';
import 'package:app_example/services/app_settings_service.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  // Ensure Flutter is initialized.
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize all our settings before the app starts.
  await appSettings.init();

  runApp(const App());
}
