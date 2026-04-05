import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Enum representing the supported environments.
enum Env { dev, prod }

/// Singleton class that manages environment-specific configuration.
///
/// Usage:
///   In main.dart call `await Environment.instance.initialize(Env.dev);`
///   Then anywhere: `Environment.instance.revenueCatApiKey`
class Environment {
  // ── Singleton boilerplate ──────────────────────────────────────────────────

  Environment._internal();

  static final Environment instance = Environment._internal();

  // ── State ──────────────────────────────────────────────────────────────────

  Env _currentEnv = Env.dev;
  bool _initialized = false;

  // ── Public API ─────────────────────────────────────────────────────────────

  /// The currently active environment.
  Env get currentEnv => _currentEnv;

  /// Returns `true` when running in production.
  bool get isProd => _currentEnv == Env.prod;

  /// Returns `true` when running in development / debug.
  bool get isDev => _currentEnv == Env.dev;

  /// Platform-specific RevenueCat API key read from the loaded .env file.
  String get revenueCatApiKey {
    _assertInitialized();
    if (Platform.isIOS) {
      return dotenv.env['REVENUECAT_API_KEY_IOS'] ?? '';
    }
    return dotenv.env['REVENUECAT_API_KEY_ANDROID'] ?? '';
  }

  /// The raw APP_ENV value from the .env file.
  String get appEnvName {
    _assertInitialized();
    return dotenv.env['APP_ENV'] ?? _currentEnv.name;
  }

  // ── Initialization ─────────────────────────────────────────────────────────

  /// Call once at app startup **before** any feature code runs.
  ///
  /// ```dart
  /// await Environment.instance.initialize(Env.dev);
  /// ```
  Future<void> initialize(Env env) async {
    if (_initialized) return;

    _currentEnv = env;

    final fileName = env == Env.prod ? '.env.prod' : '.env.dev';

    try {
      await dotenv.load(fileName: fileName);
      debugPrint('🌿 Environment loaded: $fileName');
    } catch (e) {
      debugPrint('⚠️  Could not load $fileName – $e');
    }

    _initialized = true;
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  void _assertInitialized() {
    assert(
      _initialized,
      'Environment.initialize() must be called before accessing env values.',
    );
  }
}
