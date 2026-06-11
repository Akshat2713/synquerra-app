// presentation/pages/alerts_errors/alerts_errors_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/alerts_errors/alerts_errors_bloc.dart';
import 'widgets/alerts_errors_tab.dart';

class AlertsErrorsScreen extends StatefulWidget {
  final String imei;
  const AlertsErrorsScreen({super.key, required this.imei});

  @override
  State<AlertsErrorsScreen> createState() => _AlertsErrorsScreenState();
}

class _AlertsErrorsScreenState extends State<AlertsErrorsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<AlertsErrorsBloc>().add(
      AlertsErrorsLoadRequested(widget.imei),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // alerts_errors_screen.dart - remove MultiBlocProvider from build()
  @override
  Widget build(BuildContext context) {
    // final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Alerts & Errors')),
      bottomNavigationBar: TabBar(
        controller: _tabController,

        tabs: const [
          Tab(text: 'Alerts', icon: Icon(Icons.notifications_rounded)),
          Tab(text: 'Errors', icon: Icon(Icons.bug_report_rounded)),
        ],
      ),

      body: TabBarView(
        controller: _tabController,
        children: const [
          AlertsErrorsTab(type: AlertsErrorsTabType.alerts),
          AlertsErrorsTab(type: AlertsErrorsTabType.errors),
        ],
      ),
    );
  }
}
