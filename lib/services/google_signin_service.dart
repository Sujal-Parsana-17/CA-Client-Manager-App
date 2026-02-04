import 'package:google_sign_in/google_sign_in.dart';
import './auth_service.dart';

class GoogleSignInService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
    ],
  );
  
  final AuthService _authService = AuthService();

  /// Sign in with Google and return account or throw detailed error
  Future<GoogleSignInAccount?> signIn() async {
    try {
      // First try silent sign-in (useful if the user already granted consent)
      final silent = await _googleSignIn.signInSilently();
      if (silent != null) {
        print('[GoogleSignIn] Silent sign-in succeeded: ${silent.email}');
        // Ensure local user exists
        await _authService.googleSignUp(silent.email, silent.displayName ?? 'User');
        return silent;
      }

      // Otherwise, perform interactive sign-in
      print('[GoogleSignIn] Attempting interactive sign-in...');
      final account = await _googleSignIn.signIn();
      if (account != null) {
        print('[GoogleSignIn] Interactive sign-in succeeded: ${account.email}');
        await _authService.googleSignUp(account.email, account.displayName ?? 'User');
      } else {
        // account == null means the user cancelled the sign-in flow
        print('[GoogleSignIn] User cancelled the sign-in flow');
        throw GoogleSignInException('User cancelled the sign-in');
      }
      return account;
    } on GoogleSignInException catch (e) {
      print('[GoogleSignIn] GoogleSignInException: $e');
      rethrow;
    } catch (e, st) {
      print('[GoogleSignIn] Unexpected error: $e');
      print(st);
      // Provide helpful error messages based on error type
      if (e.toString().contains('PLAY_SERVICES')) {
        throw GoogleSignInException(
          'Google Play Services not available. Please install Google Play Services.',
        );
      } else if (e.toString().contains('network')) {
        throw GoogleSignInException(
          'Network error. Please check your internet connection.',
        );
      } else if (e.toString().contains('10:')) {
        throw GoogleSignInException(
          'OAuth configuration error. Please ensure the app is correctly configured in Google Cloud Console with the correct SHA-1 and package name.',
        );
      } else {
        throw GoogleSignInException('Sign-in failed: ${e.toString()}');
      }
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _authService.logout();
    } catch (e) {
      print('Error signing out: $e');
      rethrow;
    }
  }

  Future<GoogleSignInAccount?> getCurrentUser() async {
    return _googleSignIn.currentUser;
  }

  Stream<GoogleSignInAccount?> onCurrentUserChanged() {
    return _googleSignIn.onCurrentUserChanged;
  }
}

/// Custom exception for Google Sign-In errors
class GoogleSignInException implements Exception {
  final String message;
  GoogleSignInException(this.message);

  @override
  String toString() => message;
}
