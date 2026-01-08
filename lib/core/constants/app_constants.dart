/// App-wide constants
class AppConstants {
  AppConstants._();

  static const String appName = 'RT OneStop';
  static const String appVersion = '1.0.0';

  // Disclaimer text
  static const String disclaimerTitle = 'Important Disclaimer';
  static const String disclaimerText = '''
RT OneStop is for educational and reference purposes only. It does not constitute medical advice.

Always follow your institution's protocols, physician orders, and local guidelines.

The developers are not liable for clinical decisions made using this app.

By using this app, you acknowledge that you understand these limitations and agree to use this information responsibly.
''';

  // Storage keys
  static const String disclaimerAcknowledgedKey = 'disclaimer_acknowledged';
  static const String defaultUnitSystemKey = 'default_unit_system';
  static const String themeModeKey = 'theme_mode';
  static const String favoriteCalculatorsKey = 'favorite_calculators';
  static const String favoriteReferencesKey = 'favorite_references';

  // Hive box names
  static const String preferencesBox = 'preferences';
  static const String historyBox = 'calculation_history';
  static const String feedCacheBox = 'feed_cache';
  static const String protocolStateBox = 'protocol_state';

  // Feed URLs
  static const String aarcNewsUrl = 'https://www.aarc.org/all-news/';
  static const String nbrcNewsUrl = 'https://www.nbrc.org/news/';
  static const String aarcPodcastRssUrl = 'https://feeds.buzzsprout.com/1512487.rss';

  // Report issue email
  static const String reportIssueEmail = 'support@rtonestop.com';
}

/// Unit systems
enum UnitSystem {
  metric,
  imperial,
}

/// Theme modes
enum AppThemeMode {
  light,
  dark,
  system,
}
