import 'package:flutter/material.dart';
import 'core/di/injection_container.dart';
import 'presentation/app/my_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  runApp(const MyApp());
}
