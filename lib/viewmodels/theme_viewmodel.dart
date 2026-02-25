import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class ThemeViewModel extends ChangeNotifier {
  final StorageService _storage = StorageService();

  bool isDark = false;

  Future<void> loadTheme() async {
    isDark = await _storage.isDarkMode();
    notifyListeners();
  }

  Future<void> toggleTheme(bool value) async {
    isDark = value;
    await _storage.setDarkMode(value);
    notifyListeners();
  }
}