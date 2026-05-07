import 'package:flutter/material.dart';
import '../app/app_router.dart';
import '../themes/app_theme.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Synquerra',
      debugShowCheckedModeBanner: false,

      // ── Themes ──────────────────────────────────────
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // will be driven by ThemeBloc when built
      // ── Routing ─────────────────────────────────────
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
