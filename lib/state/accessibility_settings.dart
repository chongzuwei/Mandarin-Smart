import 'package:flutter/material.dart';

class AccessibilitySettings extends ChangeNotifier {
  AccessibilitySettings({
    double textScale = 1.0,
    ThemeMode themeMode = ThemeMode.dark,
  })  : _textScale = textScale,
        _themeMode = themeMode;

  double _textScale;
  ThemeMode _themeMode;

  double get textScale => _textScale;
  ThemeMode get themeMode => _themeMode;

  void setTextScale(double value) {
    final next = value.clamp(0.85, 1.4);
    if (next == _textScale) return;
    _textScale = next;
    notifyListeners();
  }

  void setThemeMode(ThemeMode value) {
    if (value == _themeMode) return;
    _themeMode = value;
    notifyListeners();
  }
}

