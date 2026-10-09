import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/realtime/device_event.dart';
import '../../../domain/usecases/realtime/watch_device_events_usecase.dart';

class DeviceEventsCubit extends Cubit<DeviceEvent?> {
  DeviceEventsCubit(this._watch) : super(null);
  final WatchDeviceEventsUseCase _watch;
  StreamSubscription<DeviceEvent>? _sub;
  String? _userId;

  void start(String userId) {
    if (_userId == userId) return;
    _userId = userId;
    _sub?.cancel();
    _sub = _watch(userId).listen(emit);
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    _watch.stop();
    return super.close();
  }
}
