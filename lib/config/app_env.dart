class AppEnv {
  static const String supabaseUrl = String.fromEnvironment('SB_URL');
  static const String supabaseAnonKey = String.fromEnvironment('SB_ANON');
  static const String oneSignalAppId = String.fromEnvironment('OS_APP_ID');
  static const String affiseAppId = String.fromEnvironment('AFF_APP_ID');
  static const String affiseSecret = String.fromEnvironment('AFF_SECRET');

  static const int gateTimeoutSeconds = 8;
  static const int endpointProbeSeconds = 6;
  static const Duration endpointCacheTtl = Duration(hours: 24);

  static bool get hasSupabase =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
  static bool get hasOneSignal => oneSignalAppId.isNotEmpty;
  static bool get hasAffise => affiseAppId.isNotEmpty && affiseSecret.isNotEmpty;
}
