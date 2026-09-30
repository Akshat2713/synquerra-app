// lib/presentation/screens/main_shell/main_tabs.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/injection_container.dart';
import '../../blocs/device_list/device_list_bloc.dart';
import '../../blocs/manage_devices/manage_devices_bloc.dart';
import '../../blocs/manage_users/manage_users_bloc.dart';
import '../../blocs/profile/profile_bloc.dart';
import '../../blocs/schedule_list/schedule_list_bloc.dart';
import '../device_list/device_list_screen.dart';
import '../manage_devices/manage_devices_page.dart';
import '../manage_users/manage_users_screen.dart';
import '../profile/profile_screen.dart';
import '../user_schedule/schedules_list_screen.dart';
import 'main_tab.dart';

/// Single source of truth for the bottom navigation.
/// To add/remove/reorder a tab, edit only this list.
final List<MainTab> mainTabs = [
  MainTab(
    label: 'Devices',
    icon: Icons.devices_other_outlined,
    selectedIcon: Icons.devices_other_rounded,
    // DeviceListBloc + AlertsBloc are provided above the shell (router).
    builder: (_) => const DeviceListScreen(),
  ),
  MainTab(
    label: 'Schedules',
    icon: Icons.calendar_month_outlined,
    selectedIcon: Icons.calendar_month_rounded,
    builder: (_) => BlocProvider(
      create: (_) => sl<ScheduleListBloc>(),
      child: const SchedulesListScreen(),
    ),
  ),
  MainTab(
    label: 'Mappings',
    icon: Icons.developer_board_outlined,
    selectedIcon: Icons.developer_board_rounded,
    builder: (_) => BlocProvider(
      create: (ctx) =>
          sl<ManageDevicesBloc>(param1: ctx.read<DeviceListBloc>()),
      child: const ManageDevicesPage(),
    ),
  ),
  MainTab(
    label: 'Members',
    icon: Icons.people_alt_outlined,
    selectedIcon: Icons.people_alt_rounded,
    builder: (_) => BlocProvider(
      create: (_) => sl<ManageUsersBloc>(),
      child: const ManageUsersScreen(),
    ),
  ),
  MainTab(
    label: 'Profile',
    icon: Icons.person_outline_rounded,
    selectedIcon: Icons.person_rounded,
    builder: (_) => BlocProvider(
      create: (_) => sl<ProfileBloc>(),
      child: const ProfileScreen(),
    ),
  ),
];
