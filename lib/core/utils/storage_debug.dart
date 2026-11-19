import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

Future<void> logTopFolders() async {
  final roots = {
    'temp': await getTemporaryDirectory(),
    'support': await getApplicationSupportDirectory(),
    'documents': await getApplicationDocumentsDirectory(),
  };
  for (final r in roots.entries) {
    final children = r.value.existsSync()
        ? r.value.listSync()
        : <FileSystemEntity>[];
    for (final c in children) {
      final size = c is File
          ? await c.length()
          : await _dirSize(c as Directory);
      debugPrint(
        'STORAGE ${r.key}/${c.path.split('/').last}: ${(size / 1048576).toStringAsFixed(1)} MB',
      );
    }
  }
}

Future<int> _dirSize(Directory d) async {
  int t = 0;
  await for (final e in d.list(recursive: true, followLinks: false)) {
    if (e is File) t += await e.length();
  }
  return t;
}
