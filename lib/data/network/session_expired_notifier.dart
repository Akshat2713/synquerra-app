// core/network/session_expired_notifier.dart
import 'dart:async';

class SessionExpiredNotifier {
  final _controller = StreamController<void>.broadcast();
  Stream<void> get stream => _controller.stream;

  void notify() {
    if (!_controller.isClosed) _controller.add(null);
  }

  void dispose() => _controller.close();
}
