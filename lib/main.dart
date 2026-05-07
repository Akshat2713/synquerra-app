import 'package:flutter/material.dart';
import 'rework/core/di/injection_container.dart';
import 'rework/presentation/app/my_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  runApp(const MyApp());
}
