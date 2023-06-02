import 'dart:async';
import '../bloc/general_methods.dart';

class TimerClass {
  Timer? _timer;

  void startLocationUpdates() {
    _timer = Timer.periodic(const Duration(seconds: 10), (_) {
      updateLocation();
    });
  }

  void stopLocationUpdates() {
    _timer?.cancel();
  }
}
