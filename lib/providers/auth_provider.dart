import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/auth_service.dart';
import '../data/services/local_storage_service.dart';
import '../data/services/sync_service.dart';

enum AuthStatus { uninitialized, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final SyncService? _syncService;
  final Future<void> Function()? _onAfterSync;
  User? _user;
  AuthStatus _status = AuthStatus.uninitialized;
  bool _isLoading = false;
  bool _isRegistering = false;
  String? _error;
  bool _isEmailConflict = false;

  User? get user => _user;
  AuthStatus get status => _status;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isEmailConflict => _isEmailConflict;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  AuthProvider({SyncService? syncService, Future<void> Function()? onAfterSync})
      : _syncService = syncService,
        _onAfterSync = onAfterSync {
    _authService.authStateChanges.listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? user) async {
    _user = user;
    _status = user != null
        ? AuthStatus.authenticated
        : AuthStatus.unauthenticated;
    _isLoading = false;
    notifyListeners();
    if (user != null && !_isRegistering) {
      await _authService.ensureUserDocExists(user);
      await _clearLocalDataIfDifferentUser(user.uid);
      await _syncService?.syncNow();
      await _onAfterSync?.call();
    }
  }

  Future<bool> register(String email, String password, String name) async {
    _isLoading = true;
    _isRegistering = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _authService.registerWithEmail(
        email: email,
        password: password,
        name: name,
      );

      _isLoading = false;
      _isEmailConflict = result.isEmailConflict;
      if (result.isSuccess) {
        _user = _authService.currentUser;
        await _user?.reload();
        _user = _authService.currentUser;
        await _resetLocalDataForFreshUser(_user!.uid);
        _status = AuthStatus.authenticated;
        await _onAfterSync?.call();
        notifyListeners();
        return true;
      } else {
        _error = result.error;
        notifyListeners();
        return false;
      }
    } finally {
      _isRegistering = false;
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _authService.loginWithEmail(
      email: email,
      password: password,
    );

    _isLoading = false;
    if (result.isSuccess) {
      _user = _authService.currentUser;
      if (_user != null) {
        await _clearLocalDataIfDifferentUser(_user!.uid);
      }
      _status = AuthStatus.authenticated;
      await _syncService?.syncNow();
      await _onAfterSync?.call();
      notifyListeners();
      return true;
    } else {
      _error = result.error;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> _resetLocalDataForFreshUser(String uid) async {
    await LocalStorageService.clearUserTravelData();
    await LocalStorageService.saveActiveUserId(uid);
  }

  Future<void> _clearLocalDataIfDifferentUser(String uid) async {
    final activeUserId = LocalStorageService.getActiveUserId();
    if (activeUserId == uid) return;
    await LocalStorageService.clearUserTravelData();
    await LocalStorageService.saveActiveUserId(uid);
  }
}
