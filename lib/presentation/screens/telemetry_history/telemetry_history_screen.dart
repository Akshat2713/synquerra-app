import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/device/device_entity.dart';
import '../../blocs/analytics/analytics_bloc.dart';
import '../../widgets/analytics_filter_sheet.dart';
import 'empty_view.dart';
import 'error_view.dart';
import 'telemetry_list.dart';

class TelemetryHistoryScreen extends StatefulWidget {
  // final DeviceEntity device;
  final DeviceEntity device;

  const TelemetryHistoryScreen({super.key, required this.device});

  @override
  State<TelemetryHistoryScreen> createState() => _TelemetryHistoryScreenState();
}

class _TelemetryHistoryScreenState extends State<TelemetryHistoryScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AnalyticsBloc>().add(AnalyticsLoadDefault(widget.device.imei));
  }

  void _onFilterSelected(AnalyticsFilter filter) {
    context.read<AnalyticsBloc>().add(
      AnalyticsFilterChanged(imei: widget.device.imei, filter: filter),
    );
  }

  void _onCustomSelected(DateTime start, DateTime end) {
    context.read<AnalyticsBloc>().add(
      AnalyticsCustomRangeSelected(
        imei: widget.device.imei,
        startDate: start,
        endDate: end,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Telemetry History',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              'IMEI: ${widget.device.imei}',
              style: TextStyle(
                fontSize: 11,
                color: colors.onSurface.withValues(alpha: 0.6),
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        // Only the filter icon in the app bar
        actions: [
          BlocBuilder<AnalyticsBloc, AnalyticsState>(
            builder: (context, state) {
              final activeFilter = state is AnalyticsLoaded
                  ? state.activeFilter
                  : AnalyticsFilter.latest;
              return IconButton(
                icon: const Icon(Icons.filter_list_rounded),
                tooltip: 'Filter',
                onPressed: () => showAnalyticsFilterSheet(
                  context: context,
                  activeFilter: activeFilter,
                  onFilterSelected: _onFilterSelected,
                  onCustomSelected: _onCustomSelected,
                ),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<AnalyticsBloc, AnalyticsState>(
        builder: (context, state) {
          if (state is AnalyticsLoading || state is AnalyticsInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is AnalyticsError) {
            return ErrorView(message: state.message);
          }
          if (state is AnalyticsLoaded) {
            if (state.points.isEmpty) {
              return EmptyView(filter: state.activeFilter);
            }
            return TelemetryList(
              points: state.points,
              filter: state.activeFilter,
              startDate: state.startDate,
              endDate: state.endDate,
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
