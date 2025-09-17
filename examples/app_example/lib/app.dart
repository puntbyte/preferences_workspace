import 'package:app_example/services/app_settings_service.dart';
import 'package:app_example/ui/home_page.dart';
import 'package:flutter/material.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    // ListenableBuilder efficiently rebuilds only this part of the tree
    // when theme-related settings change.
    return ListenableBuilder(
      listenable: appSettings.regular,
      builder: (context, child) {
        return MaterialApp(
          title: 'Preferences Demo',
          debugShowCheckedModeBanner: false,
          themeMode: appSettings.regular.themeMode,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: appSettings.regular.accentColor ?? Colors.deepPurple,
            ),
            useMaterial3: true,
          ),

          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: appSettings.regular.accentColor ?? Colors.deepPurple,
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
          ),

          home: child,
        );
      },
      child: const HomePage(),
    );
  }
}
