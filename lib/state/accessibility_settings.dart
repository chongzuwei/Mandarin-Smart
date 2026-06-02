import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccessibilitySettings extends ChangeNotifier {
  double _textScale;
  ThemeMode _themeMode;

  AccessibilitySettings({
    double textScale = 1.0,
    ThemeMode themeMode = ThemeMode.system,
  })  : _textScale = textScale,
        _themeMode = themeMode;

  double get textScale => _textScale;

  ThemeMode get themeMode => _themeMode;

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    _textScale = prefs.getDouble('textScale') ?? 1.0;

    final themeIndex = prefs.getInt('themeMode') ?? 0;

    _themeMode = ThemeMode.values[themeIndex];

    notifyListeners();
  }

  Future<void> setTextScale(double value) async {
    _textScale = value;

    final prefs = await SharedPreferences.getInstance();

    await prefs.setDouble('textScale', value);

    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;

    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt(
      'themeMode',
      mode.index,
    );

    notifyListeners();
  }
}