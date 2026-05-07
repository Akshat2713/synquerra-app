// lib/presentation/screens/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import '../../../business/blocs/navigation_bloc/navigation_bloc.dart';
import '../../widgets/core/app_card.dart';
import '../../widgets/core/app_empty.dart';
import '../../themes/colors.dart';
import 'map_screen.dart';
import '../settings/settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider.value(value: context.read<NavigationBloc>())],
      child: const HomeView(),
    );
  }
}

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BlocBuilder<NavigationBloc, NavigationState>(
      builder: (context, state) {
        return Scaffold(
          body: IndexedStack(
            index: state.selectedIndex,
            children: const [
              MapScreen(),
              _ComingSoonScreen(
                title: "Location History",
                icon: Icons.history_edu_sharp,
              ),
              _ComingSoonScreen(
                title: "Notifications",
                icon: Icons.notifications,
              ),
              SettingsScreen(),
            ],
          ),
          bottomNavigationBar: Material(
            elevation: 12,
            color: colorScheme.surface,
            child: SalomonBottomBar(
              currentIndex: state.selectedIndex,
              onTap: (index) {
                context.read<NavigationBloc>().add(
                  NavigationTabChanged(index: index),
                );
              },
              items: [
                SalomonBottomBarItem(
                  icon: const Icon(Icons.home),
                  title: const Text("Home"),
                  selectedColor: AppColors.navBlue,
                ),
                SalomonBottomBarItem(
                  icon: const Icon(Icons.history_edu_sharp),
                  title: const Text("History"),
                  selectedColor: AppColors.navBlue,
                ),
                SalomonBottomBarItem(
                  icon: const Icon(Icons.notifications),
                  title: const Text("Alerts"),
                  selectedColor: AppColors.navBlue,
                ),
                SalomonBottomBarItem(
                  icon: const Icon(Icons.settings),
                  title: const Text("Settings"),
                  selectedColor: AppColors.navBlue,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Internal widget for "Coming Soon" screens - keeps home_screen.dart clean
class _ComingSoonScreen extends StatelessWidget {
  final String title;
  final IconData icon;

  const _ComingSoonScreen({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon with gradient background
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.navBlue.withValues(alpha: 0.1),
                    AppColors.navBlue.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 64,
                color: AppColors.navBlue.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Coming Soon",
              style: TextStyle(
                fontSize: 16,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "This feature is under development",
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
