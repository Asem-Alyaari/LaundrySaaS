import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SessionStorage {
  static const String _keyToken = 'customer_access_token';
  static const String _keyUser = 'customer_user_profile';
  static const String _keyIsGuest = 'customer_is_guest';

  /// Save access token
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, token);
  }

  /// Get stored token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  /// Save user profile as JSON
  static Future<void> saveUserProfile(Map<String, dynamic> userMap) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUser, json.encode(userMap));
  }

  /// Get stored user profile
  static Future<Map<String, dynamic>?> getUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyUser);
    if (raw == null) return null;
    try {
      return json.decode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  /// Set guest mode
  static Future<void> setGuestMode(bool isGuest) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsGuest, isGuest);
  }

  /// Check if guest mode
  static Future<bool> isGuestMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsGuest) ?? false;
  }

  /// Clear session (logout)
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
    await prefs.remove(_keyUser);
    await prefs.remove(_keyIsGuest);
  }
}
