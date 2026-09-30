// lib/presentation/screens/main_shell/main_shell_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../app/app_router.dart';
import '../../blocs/auth/auth_bloc.dart';
import 'main_shell_cubit.dart';
import 'main_tab.dart';
import 'main_tabs.dart';

class MainShellScreen extends StatelessWidget {
  /// Injectable for testing / role-based tabs. Defaults to [mainTabs].
  final List<MainTab>? tabs;
  const MainShellScreen({super.key, this.tabs});

  @override
  Widget build(BuildContext context) {
    final tabs = this.tabs ?? mainTabs;

    return BlocProvider(
      create: (_) => MainShellCubit(),
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthUnauthenticated) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.login,
              (_) => false,
            );
          }
        },
        child: BlocBuilder<MainShellCubit, int>(
          builder: (context, index) => PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, _) async {
              if (didPop) return;
              if (index != 0) {
                context.read<MainShellCubit>().select(0);
              } else {
                await SystemNavigator.pop();
              }
            },
            child: Scaffold(
              body: _LazyIndexedStack(index: index, tabs: tabs),
              bottomNavigationBar: NavigationBar(
                selectedIndex: index,
                onDestinationSelected: context.read<MainShellCubit>().select,
                destinations: [
                  for (final t in tabs)
                    NavigationDestination(
                      icon: Icon(t.icon),
                      selectedIcon: Icon(t.selectedIcon),
                      label: t.label,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Keeps every visited tab alive (state preserved), but only builds a tab
/// the first time it is opened.
class _LazyIndexedStack extends StatefulWidget {
  final int index;
  final List<MainTab> tabs;
  const _LazyIndexedStack({required this.index, required this.tabs});

  @override
  State<_LazyIndexedStack> createState() => _LazyIndexedStackState();
}

class _LazyIndexedStackState extends State<_LazyIndexedStack> {
  final Map<int, Widget> _built = {};

  Widget _tabAt(int i) =>
      _built.putIfAbsent(i, () => widget.tabs[i].builder(context));

  @override
  Widget build(BuildContext context) {
    _tabAt(widget.index);
    return IndexedStack(
      index: widget.index,
      children: [
        for (var i = 0; i < widget.tabs.length; i++)
          _built.containsKey(i) ? _built[i]! : const SizedBox.shrink(),
      ],
    );
  }
}
