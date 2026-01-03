import 'dart:async';
import '../models/sensor_data.dart';

class AppState {
  final StreamController<SensorData> _controller =
      StreamController<SensorData>.broadcast();

  Stream<SensorData> get stream => _controller.stream;

  void update(SensorData data) {
    _controller.add(data);
  }

  void dispose() {
    _controller.close();
  }
}
