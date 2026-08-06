class MapConfig {
  MapConfig._();

  /// Passed at build time via `--dart-define=LOCATIONIQ_API_KEY=your_key`
  /// or `--dart-define-from-file=config.json`
  static const String _apiKey = String.fromEnvironment(
    'LOCATIONIQ_API_KEY',
    defaultValue: '',
  );

  /// LocationIQ map themes: 'streets', 'dark', or 'light'
  static const String _mapTheme = 'streets';

  /// LocationIQ standard raster tile URL template.
  static const String tileUrlTemplate =
      'https://tiles.locationiq.com/v3/$_mapTheme/r/{z}/{x}/{y}.png?key=$_apiKey';

  /// Package name sent in the HTTP User-Agent header.
  static const String userAgentPackageName = 'com.synquerra.app';

  /// Default zoom level when no filter / route is active.
  static const double defaultZoom = 14.0;
}
