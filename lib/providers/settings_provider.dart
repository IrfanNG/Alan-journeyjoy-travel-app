import 'package:flutter/foundation.dart';

import '../data/models/app_settings_model.dart';
import '../data/services/local_storage_service.dart';

class SettingsProvider extends ChangeNotifier {
  late AppSettings _settings;

  AppSettings get settings => _settings;

  void loadSettings() {
    _settings = LocalStorageService.getSettings();
    notifyListeners();
  }

  bool get isDarkMode => _settings.darkModeEnabled;

  void setUsername(String name) {
    _settings.username = name;
    LocalStorageService.saveSettings(_settings);
    notifyListeners();
  }

  void setDarkMode(bool value) {
    _settings.darkModeEnabled = value;
    LocalStorageService.saveSettings(_settings);
    notifyListeners();
  }

  void markWelcomeSeen() {
    _settings.hasSeenWelcome = true;
    LocalStorageService.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> clearCache() async {
    await LocalStorageService.clearAll();
    _settings = AppSettings();
    notifyListeners();
  }
}
