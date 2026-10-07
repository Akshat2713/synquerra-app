import 'package:flutter/material.dart';
import 'core/bootstrap/app_bootstrap.dart';
import 'presentation/app/my_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await bootstrapApp();
  runApp(const MyApp());
}
