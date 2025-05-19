import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart'; // For ChangeNotifier

// Define keys for SharedPreferences
const String kDarkModeEnabled = 'darkModeEnabled';
const String kNotificationEnabled = 'notificationEnabled';
const String kSelectedLanguage = 'selectedLanguage';
const String kFontSizeMultiplier = 'fontSizeMultiplier';
const String kUserNickname = 'userNickname';

class SettingsService with ChangeNotifier {
  late SharedPreferences _prefs;

  // Default values
  bool _darkModeEnabled = false;
  bool _notificationEnabled = true;
  String _selectedLanguage = 'en'; // e.g., 'en', 'es', 'fr'
  double _fontSizeMultiplier = 1.0; // 1.0 is normal, <1 smaller, >1 larger
  String _userNickname = '';

  // Getters
  bool get darkModeEnabled => _darkModeEnabled;
  bool get notificationEnabled => _notificationEnabled;
  String get selectedLanguage => _selectedLanguage;
  double get fontSizeMultiplier => _fontSizeMultiplier;
  String get userNickname => _userNickname;

  SettingsService() {
    _loadPreferences();
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> _loadPreferences() async {
    await _initPrefs(); // Ensure prefs is initialized

    _darkModeEnabled = _prefs.getBool(kDarkModeEnabled) ?? false;
    _notificationEnabled = _prefs.getBool(kNotificationEnabled) ?? true;
    _selectedLanguage = _prefs.getString(kSelectedLanguage) ?? 'en';
    _fontSizeMultiplier = _prefs.getDouble(kFontSizeMultiplier) ?? 1.0;
    _userNickname = _prefs.getString(kUserNickname) ?? '';

    notifyListeners(); // Notify listeners after loading
  }

  // Setters
  Future<void> setDarkMode(bool value) async {
    _darkModeEnabled = value;
    await _prefs.setBool(kDarkModeEnabled, value);
    notifyListeners();
  }

  Future<void> setNotificationEnabled(bool value) async {
    _notificationEnabled = value;
    await _prefs.setBool(kNotificationEnabled, value);
    notifyListeners();
  }

  Future<void> setSelectedLanguage(String value) async {
    _selectedLanguage = value;
    await _prefs.setString(kSelectedLanguage, value);
    notifyListeners();
  }

  Future<void> setFontSizeMultiplier(double value) async {
    _fontSizeMultiplier = value;
    await _prefs.setDouble(kFontSizeMultiplier, value);
    notifyListeners();
  }

  Future<void> setUserNickname(String value) async {
    _userNickname = value;
    await _prefs.setString(kUserNickname, value);
    notifyListeners();
  }
}
