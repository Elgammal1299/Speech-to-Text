import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class ThemeProvider extends ChangeNotifier {
  final StorageService _storageService = StorageService();
  bool _isDarkMode = false;
  bool _isLoading = true;

  bool get isDarkMode => _isDarkMode;
  bool get isLoading => _isLoading;

  ThemeProvider() {
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    _isDarkMode = await _storageService.getDarkTheme();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    await _storageService.setDarkTheme(_isDarkMode);
    notifyListeners();
  }

  Future<void> setTheme(bool isDark) async {
    if (_isDarkMode != isDark) {
      _isDarkMode = isDark;
      await _storageService.setDarkTheme(_isDarkMode);
      notifyListeners();
    }
  }
}
