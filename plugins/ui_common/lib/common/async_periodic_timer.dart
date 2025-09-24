part of '../ui_common.dart';

class AsyncPeriodicTimer {
  final Duration interval;
  final Future<void> Function() asyncCallback;
  bool _isRunning = false;
  Timer? _timer;

  AsyncPeriodicTimer(this.interval, this.asyncCallback);

  void start() {
    if (_isRunning) return;
    _isRunning = true;

    Future<void> tick() async {
      if (!_isRunning) return;
      await asyncCallback();
      if (_isRunning) {
        _timer = Timer(interval, tick);
      }
    }

    tick(); // Start the loop
  }

  void cancel() {
    _isRunning = false;
    _timer?.cancel();
  }

  bool get isActive => _isRunning;
}
