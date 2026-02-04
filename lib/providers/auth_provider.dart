import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/google_signin_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  int? _userId;

  bool get isAuthenticated => _userId != null;
  int? get userId => _userId;

  Future<void> loadCurrentUser() async {
    _userId = await _authService.getCurrentUserId();
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    final id = await _authService.login(email, password);
    if (id != null) {
      _userId = id;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<int> signup(String email, String password, {String? name}) async {
    final id = await _authService.signup(email, password, name: name);
    _userId = id;
    await _authService.login(email, password);
    notifyListeners();
    return id;
  }

  Future<void> logout() async {
    await _authService.logout();
    // Also sign out from Google to clear cached Google session
    try {
      final google = GoogleSignInService();
      await google.signOut();
    } catch (e) {
      print('Error signing out from Google: $e');
      // Continue logout even if Google sign-out fails
    }
    _userId = null;
    notifyListeners();
  }

  /// Sign in using Google and update provider state.
  /// Returns true when signed in and provider updated.
  Future<bool> signInWithGoogle() async {
    try {
      final google = GoogleSignInService();
      final account = await google.signIn();
      if (account == null) return false;

      // auth_service.googleSignUp already creates/logs in the user and writes prefs.
      // Ensure we read the current user id and update provider state.
      _userId = await _authService.getCurrentUserId();
      notifyListeners();
      return _userId != null;
    } catch (e) {
      return false;
    }
  }
}
