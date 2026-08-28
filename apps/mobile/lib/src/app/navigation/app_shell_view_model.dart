import 'package:flutter/material.dart';

class AppShellViewModel extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;
  int _selectedIndex = 0;

  ThemeMode get themeMode => _themeMode;
  int get selectedIndex => _selectedIndex;

  void selectDestination(int index) {
    if (_selectedIndex == index) return;
    _selectedIndex = index;
    notifyListeners();
  }

  void toggleTheme() {
    _themeMode =
        _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }
}
