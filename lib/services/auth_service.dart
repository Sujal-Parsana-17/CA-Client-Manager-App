import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/database_helper.dart';

class AuthService {
  static const _currentUserKey = 'current_user_id';

  final dbHelper = DatabaseHelper.instance;

  Future<int> signup(String email, String password, {String? name}) async {
    final db = await dbHelper.database;
    final now = DateTime.now().toIso8601String();
    final passwordHash = _hashPassword(password);

    final user = {
      'email': email,
      'passwordHash': passwordHash,
      'name': name ?? '',
      'createdAt': now,
    };

    return await db.insert('users', user);
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final db = await dbHelper.database;
    final results = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<int?> login(String email, String password) async {
    final user = await getUserByEmail(email);
    if (user == null) return null;
    final hash = user['passwordHash'] as String;
    if (hash == _hashPassword(password)) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_currentUserKey, user['id'] as int);
      return user['id'] as int;
    }
    return null;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserKey);
  }

  Future<int?> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_currentUserKey);
  }

  Future<int> googleSignUp(String email, String name) async {
    // Check if user already exists
    final existingUser = await getUserByEmail(email);
    if (existingUser != null) {
      // User exists, just log them in
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_currentUserKey, existingUser['id'] as int);
      return existingUser['id'] as int;
    }

    // Create new user with Google sign-in
    final db = await dbHelper.database;
    final now = DateTime.now().toIso8601String();
    // For Google sign-in, we use a placeholder password hash
    final passwordHash = _hashPassword('google_signin_${email}_${DateTime.now()}');

    final user = {
      'email': email,
      'passwordHash': passwordHash,
      'name': name,
      'createdAt': now,
    };

    final userId = await db.insert('users', user);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_currentUserKey, userId);
    return userId;
  }

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
