/// Map tile configuration — centralised so the tile URL / user-agent
/// is never hardcoded inside a screen.
class MapTileConfig {
  MapTileConfig._();

  /// OpenStreetMap standard tile URL.
  static const String tileUrlTemplate =
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

  /// Package name sent in the HTTP User-Agent header (required by OSM policy).
  static const String userAgentPackageName = 'com.synquerra.app';

  /// Default zoom level when no filter / route is active.
  static const double defaultZoom = 14.0;
}
