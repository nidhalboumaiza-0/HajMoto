enum AppEnvironment { test, production }

/// Central configuration read from compile-time Dart defines.
/// Access via [AppConfig.env], [AppConfig.isTestMode], etc.
class AppConfig {
  AppConfig._();

  static AppEnvironment _env = AppEnvironment.test;

  static void init() {
    const raw = String.fromEnvironment('APP_ENV', defaultValue: 'test');
    _env = raw.trim().toLowerCase() == 'production'
        ? AppEnvironment.production
        : AppEnvironment.test;
  }

  static AppEnvironment get env => _env;

  /// True when running with fake/mock data — no database needed.
  static bool get isTestMode => _env == AppEnvironment.test;

  /// True when connected to the real Supabase backend.
  static bool get isProduction => _env == AppEnvironment.production;

  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
  );

  static String get envLabel => isTestMode ? 'MODE TEST' : 'PRODUCTION';
}
