import 'package:flutter/material.dart';

import 'app_destination.dart';

class AppShellViewModel extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;
  int _selectedIndex = 0;
  String _searchQuery = '';
  final Map<AppDestination, Map<String, String>> _filters = {};

  ThemeMode get themeMode => _themeMode;
  int get selectedIndex => _selectedIndex;
  String get searchQuery => _searchQuery;
  Map<String, String> filtersFor(AppDestination destination) =>
      Map.unmodifiable(_filters[destination] ?? const {});

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

  void updateFilters(AppDestination destination, Map<String, String> filters) {
    _filters[destination] = Map.unmodifiable(filters);
    notifyListeners();
  }
}
