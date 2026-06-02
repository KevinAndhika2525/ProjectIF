import 'package:flutter/material.dart';
import 'local_storage.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  bool _isDarkMode = false;

  ThemeProvider() {
    _loadTheme();
  }

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _isDarkMode;

  Future<void> _loadTheme() async {
    final savedThemeMode = await LocalStorage.getThemeMode();
    _isDarkMode = savedThemeMode == 'dark';
    _themeMode = _isDarkMode ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  Future<void> toggleTheme(bool isDarkMode) async {
    _isDarkMode = isDarkMode;
    _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    
    final themeMode = isDarkMode ? 'dark' : 'light';
    await LocalStorage.saveThemeMode(themeMode);
    
    notifyListeners();
  }
}