import 'package:dio_cache_interceptor_hive_store/dio_cache_interceptor_hive_store.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cache/flutter_map_cache.dart';
import 'package:path_provider/path_provider.dart';

class MapConfig {
  MapConfig._();

  static const String _apiKey = String.fromEnvironment(
    'LOCATIONIQ_API_KEY',
    defaultValue: '',
  );

  static const String _mapTheme = 'streets';

  static const String tileUrlTemplate =
      'https://tiles.locationiq.com/v3/$_mapTheme/r/{z}/{x}/{y}.png?key=$_apiKey';

  static const String userAgentPackageName = 'com.synquerra.app';

  static const double defaultZoom = 14.0;

  static HiveCacheStore? _cacheStore;

  /// Must be called once (e.g. in main() before runApp) since it needs
  /// an async directory lookup.
  static Future<void> init() async {
    final dir =
        await getTemporaryDirectory(); // tiles are disposable, temp dir is fine
    _cacheStore = HiveCacheStore(dir.path, hiveBoxName: 'map_tiles_cache');
  }

  static TileProvider get tileProvider {
    assert(
      _cacheStore != null,
      'Call MapConfig.init() before using tileProvider',
    );
    return CachedTileProvider(
      store: _cacheStore!,
      maxStale: const Duration(days: 30),
    );
  }
}
