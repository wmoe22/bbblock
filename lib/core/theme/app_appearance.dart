import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppAppearanceMode { dark, light }

class AppAppearance extends ChangeNotifier {
  AppAppearance._();

  static final AppAppearance instance = AppAppearance._();
  static const _storageKey = 'app_appearance_mode';

  AppAppearanceMode _mode = AppAppearanceMode.dark;

  AppAppearanceMode get mode => _mode;
  bool get isDark => _mode == AppAppearanceMode.dark;
  String get label => isDark ? 'Dark' : 'Light';

  Future<void> load() async {
    final preferences = await SharedPreferences.getInstance();
    _mode = preferences.getString(_storageKey) == 'light'
        ? AppAppearanceMode.light
        : AppAppearanceMode.dark;
  }

  Future<void> setMode(AppAppearanceMode mode) async {
    if (_mode == mode) return;

    _mode = mode;
    notifyListeners();

    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _storageKey,
      mode == AppAppearanceMode.light ? 'light' : 'dark',
    );
  }
}
