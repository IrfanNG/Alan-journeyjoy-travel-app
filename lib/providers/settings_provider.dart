import 'package:flutter/foundation.dart';

import '../data/models/app_settings_model.dart';
import '../data/services/local_storage_service.dart';
import '../data/services/sync_service.dart';
import '../services/notification_service.dart';

class SettingsProvider extends ChangeNotifier {
  final SyncService? _syncService;
  late AppSettings _settings;

  SettingsProvider({SyncService? syncService}) : _syncService = syncService;

  AppSettings get settings => _settings;

  void loadSettings() {
    _settings = LocalStorageService.getSettings();
    notifyListeners();
  }

  bool get isDarkMode => _settings.darkModeEnabled;

  bool get notificationsEnabled => _settings.notificationsEnabled;

  String get currencyCode => _settings.currencyCode;

  void setUsername(String name) {
    _settings.username = name;
    _settings.updatedAt = DateTime.now();
    LocalStorageService.saveSettings(_settings);
    notifyListeners();
    _syncService?.syncUpdate(
      entityType: 'settings',
      entityId: 'app',
      data: _settings.toMap(),
    );
  }

  void setDarkMode(bool value) {
    _settings.darkModeEnabled = value;
    _settings.updatedAt = DateTime.now();
    LocalStorageService.saveSettings(_settings);
    notifyListeners();
    _syncService?.syncUpdate(
      entityType: 'settings',
      entityId: 'app',
      data: _settings.toMap(),
    );
  }

  void setNotificationsEnabled(bool value) {
    _settings.notificationsEnabled = value;
    _settings.updatedAt = DateTime.now();
    LocalStorageService.saveSettings(_settings);
    notifyListeners();
    _syncService?.syncUpdate(
      entityType: 'settings',
      entityId: 'app',
      data: _settings.toMap(),
    );
    if (!value) {
      NotificationService.cancelAll();
    }
  }

  void setCurrency(String code) {
    _settings.currencyCode = code;
    _settings.updatedAt = DateTime.now();
    LocalStorageService.saveSettings(_settings);
    notifyListeners();
    _syncService?.syncUpdate(
      entityType: 'settings',
      entityId: 'app',
      data: _settings.toMap(),
    );
  }

  void markWelcomeSeen() {
    _settings.hasSeenWelcome = true;
    _settings.updatedAt = DateTime.now();
    LocalStorageService.saveSettings(_settings);
    notifyListeners();
    _syncService?.syncUpdate(
      entityType: 'settings',
      entityId: 'app',
      data: _settings.toMap(),
    );
  }

  Future<void> clearCache() async {
    await LocalStorageService.clearAll();
    _settings = AppSettings();
    notifyListeners();
  }
}
