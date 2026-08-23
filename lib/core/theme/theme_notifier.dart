import 'package:flutter/material.dart';

class ThemeNotifier extends ValueNotifier<ThemeMode> {
  // Defaults to the phone's system setting until the user explicitly
  // toggles dark mode themselves — after that, their choice is an override
  // that no longer follows the system setting.
  ThemeNotifier() : super(ThemeMode.system);

  static final ThemeNotifier instance = ThemeNotifier();

  bool get isDark => value == ThemeMode.dark;

  /// Whether the app is actually rendering dark right now — unlike [isDark],
  /// this resolves ThemeMode.system against the platform's current
  /// brightness, so toggle switches can show the true current state instead
  /// of reading as "off" while the system theme is dark.
  bool isDarkIn(BuildContext context) {
    if (value == ThemeMode.system) {
      return MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    }
    return isDark;
  }

  void toggle(BuildContext context) {
    value = isDarkIn(context) ? ThemeMode.light : ThemeMode.dark;
  }
}
