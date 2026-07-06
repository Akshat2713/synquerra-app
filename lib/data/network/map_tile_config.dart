/// Map tile configuration — centralised so the tile URL / user-agent
/// is never hardcoded inside a screen.
class MapTileConfig {
  MapTileConfig._();

  /// Your LocationIQ Access Token
  static const String _apiKey = 'pk.ff7de307cba8385db088a639dca3c0dc';

  /// LocationIQ map themes: 'streets', 'dark', or 'light'
  static const String _mapTheme = 'streets';

  /// LocationIQ standard raster tile URL template.
  static const String tileUrlTemplate =
      'https://tiles.locationiq.com/v3/$_mapTheme/r/{z}/{x}/{y}.png?key=$_apiKey';

  /// Package name sent in the HTTP User-Agent header.
  /// (Still good practice to keep for analytics/logging).
  static const String userAgentPackageName = 'com.synquerra.app';

  /// Default zoom level when no filter / route is active.
  static const double defaultZoom = 14.0;
}

/// Map tile configuration — centralised so the tile URL / user-agent
/// is never hardcoded inside a screen.
// class MapTileConfig {
//   MapTileConfig._();

//   /// OpenStreetMap standard tile URL.
//   static const String tileUrlTemplate =
//       'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

//   /// Package name sent in the HTTP User-Agent header (required by OSM policy).
//   static const String userAgentPackageName = 'com.synquerra.app';

//   /// Default zoom level when no filter / route is active.
//   static const double defaultZoom = 14.0;
// }
