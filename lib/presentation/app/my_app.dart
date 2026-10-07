// lib/presentation/app/my_app.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:synquerra/presentation/blocs/theme/theme_cubit.dart';
import '../../core/di/injection_container.dart';
import 'app_router.dart';
import '../blocs/auth/auth_bloc.dart';
import '../themes/app_palette.dart';
import '../themes/app_theme.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>(create: (_) => sl<ThemeCubit>()),
        BlocProvider<AuthBloc>(create: (_) => sl<AuthBloc>()),
      ],
      child: BlocBuilder<ThemeCubit, AppThemeType>(
        builder: (context, type) {
          return MaterialApp(
            title: 'Synquerra',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.fromType(type), // dark is just another type
            themeMode: ThemeMode.light,
            initialRoute: AppRoutes.splash,
            onGenerateRoute: AppRouter.onGenerateRoute,
          );
        },
      ),
    );
  }
}
