import 'package:shared_preferences/shared_preferences.dart';

class PreferenceService {
  static SharedPreferences? _prefs;

  // Keys
  static const String _keyUserId = 'userId';
  static const String _keyIsLoggedIn = 'isLoggedIn';
  static const String _keyOnboardingCompleted = 'onboardingCompleted';
  static const String _keyProfileCompleted = 'profileCompleted';

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // User ID - Synchronous get is fine
  static String? get userId => _prefs?.getString(_keyUserId);

  // Changed to Future to ensure it saves before moving on
  static Future<void> setUserId(String? value) async {
    if (value == null) {
      await _prefs?.remove(_keyUserId);
    } else {
      await _prefs?.setString(_keyUserId, value);
    }
  }

  // Status Getters (Synchronous is okay for reading)
  static bool get isLoggedIn => _prefs?.getBool(_keyIsLoggedIn) ?? false;
  static bool get isOnboardingCompleted => _prefs?.getBool(_keyOnboardingCompleted) ?? false;
  static bool get isProfileCompleted => _prefs?.getBool(_keyProfileCompleted) ?? false;

  // Status Setters (Now async methods to prevent data loss)
  static Future<void> setLoggedIn(bool value) async {
    await _prefs?.setBool(_keyIsLoggedIn, value);
  }

  static Future<void> setOnboardingCompleted(bool value) async {
    await _prefs?.setBool(_keyOnboardingCompleted, value);
  }

  static Future<void> setProfileCompleted(bool value) async {
    await _prefs?.setBool(_keyProfileCompleted, value);
  }

  static Future<void> logout() async {
    await _prefs?.clear();
  }
}