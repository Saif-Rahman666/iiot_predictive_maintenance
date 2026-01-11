import 'dart:async';
import '../models/sensor_data.dart';

class SensorDataService {
  final _controller = StreamController<SensorData>.broadcast();
  Stream<SensorData> get stream => _controller.stream;

  void start() {
    int tick = 0;

    Timer.periodic(const Duration(seconds: 2), (timer) {
      tick++;

      final temperature = 24 + (tick % 5);
      final rul = (100 - tick).clamp(0, 100).toDouble();
      final bool anomalyDetected = tick > 70;

      // Provide the newly required arguments
      final data = SensorData(
        timestamp: DateTime.now(),
        temperature: temperature.toDouble(),
        proximity: 300.0 + tick,
        irStatus: anomalyDetected ? "Blocked" : "Clear", // Added
        healthIndex: (1.0 - (tick / 150)).clamp(0.0, 1.0), // Added
        light: (120 + (tick % 20)).toDouble(),
        rul: rul,
        anomaly: anomalyDetected,
        anomalyReason: anomalyDetected
            ? 'RUL dropping rapidly with abnormal patterns'
            : 'All parameters within normal range',
      );

      _controller.add(data);
    });
  }

  void dispose() {
    _controller.close();
  }
}