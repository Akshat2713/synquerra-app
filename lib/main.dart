import 'package:flutter/foundation.dart'; // add (for kDebugMode)
import 'package:flutter/material.dart';
import 'core/bootstrap/app_bootstrap.dart';
import 'core/utils/storage_debug.dart'; // add (the file from Step 1)
import 'presentation/app/my_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await bootstrapApp();

  if (kDebugMode) {
    logTopFolders(); // add (no await)
  }

  runApp(const MyApp());
}
