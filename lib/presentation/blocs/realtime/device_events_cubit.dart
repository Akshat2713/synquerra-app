import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/realtime/device_event.dart';
import '../../../domain/usecases/realtime/watch_device_events_usecase.dart';

class DeviceEventsCubit extends Cubit<DeviceEvent?> {
  final WatchDeviceEventsUseCase _watch;
  StreamSubscription<DeviceEvent>? _sub;

  DeviceEventsCubit(this._watch) : super(null);

  void start(String imei) {
    _sub?.cancel();
    _sub = _watch(imei).listen(emit);
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    _watch.stop();
    return super.close();
  }
}
