class AppConfig {
  static const String appName = 'SIMS';
  static const double version = 1.0;

  // API endpoints
  static const String loginEndpoint = 'v2/login';
  static const String qrcodeVerifyEndpoint = 'v2/submitqrcode';
  static const String startAttendanceEndpoint = 'v2/start_attendance';

  // SharedPreferences keys
  static const String simsPreference = 'sims_configuration';
  static const String simsInstallationPreference = 'sims_installation';
  static const String siteUrlKey = 'SITE_URL';
  static const String collegeNameKey = 'college_name';

  // Colors
  static const int primaryColorValue = 0xFF1565C0;
  static const int secondaryColorValue = 0xFF0288D1;
  static const int accentColorValue = 0xFF00ACC1;
}
