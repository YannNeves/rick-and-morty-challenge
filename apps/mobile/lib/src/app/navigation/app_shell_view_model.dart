import 'package:flutter/material.dart';

class AppShellViewModel extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;
  int _selectedIndex = 0;
  String _searchQuery = '';

  ThemeMode get themeMode => _themeMode;
  int get selectedIndex => _selectedIndex;
  String get searchQuery => _searchQuery;

  void selectDestination(int index) {
    if (_selectedIndex == index) return;
    _selectedIndex = index;
    _searchQuery = '';
    notifyListeners();
  }

  void toggleTheme() {
    _themeMode =
        _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }

  void updateSearchQuery(String value) {
    final query = value.trim();
    if (_searchQuery == query) return;
    _searchQuery = query;
    notifyListeners();
  }
}
