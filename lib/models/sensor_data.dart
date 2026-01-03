class SensorData {
  final double temperature;
  final double proximity;
  final double light;
  final double rul;
  final bool anomaly;
  final DateTime timestamp;
  final String anomalyReason;

  SensorData({
    required this.temperature,
    required this.proximity,
    required this.light,
    required this.rul,
    required this.anomaly,
    required this.timestamp,
    required this.anomalyReason,
  });
}
