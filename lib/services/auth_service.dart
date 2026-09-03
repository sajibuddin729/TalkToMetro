import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static const String _keyLoginTimestamp = 'user_login_timestamp';
  static const String _keyUserPhone = 'user_phone_number';

  static User? get currentUser => _auth.currentUser;

  /// Check if user is currently logged in and session is within 30 days
  static Future<bool> isSessionValid() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final loginTimestamp = prefs.getInt(_keyLoginTimestamp);

      // Check Firebase auth state first
      if (_auth.currentUser != null) {
        if (loginTimestamp != null) {
          final loginDate = DateTime.fromMillisecondsSinceEpoch(loginTimestamp);
          final daysPassed = DateTime.now().difference(loginDate).inDays;
          if (daysPassed >= 30) {
            await logout();
            return false;
          }
        }
        return true;
      }

      // Check stored preference session fallback (30 days validity)
      if (loginTimestamp != null) {
        final loginDate = DateTime.fromMillisecondsSinceEpoch(loginTimestamp);
        final daysPassed = DateTime.now().difference(loginDate).inDays;
        if (daysPassed < 30) {
          return true;
        }
      }
    } catch (e) {
      debugPrint('Auth session check error: $e');
    }
    return false;
  }

  /// Save session timestamp when OTP verification succeeds
  static Future<void> saveLoginSession(String phoneNumber) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_keyLoginTimestamp, DateTime.now().millisecondsSinceEpoch);
      await prefs.setString(_keyUserPhone, phoneNumber);
    } catch (e) {
      debugPrint('Save login session error: $e');
    }
  }

  /// Sign out user and clear 30-day session
  static Future<void> logout() async {
    try {
      await _auth.signOut();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyLoginTimestamp);
      await prefs.remove(_keyUserPhone);
    } catch (e) {
      debugPrint('Logout error: $e');
    }
  }
}
