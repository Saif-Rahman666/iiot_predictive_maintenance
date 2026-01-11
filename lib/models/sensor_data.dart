class SensorData {
  final double temperature;
  final double proximity; // This will map to 'ir_raw'
  final String irStatus;  // "Blocked" or "Clear"
  final double healthIndex; 
  final double rul;
  final bool anomaly;
  final DateTime timestamp;
  final String anomalyReason;
  final double light;

  SensorData({
    required this.temperature,
    required this.proximity,
    required this.irStatus,
    required this.healthIndex,
    required this.rul,
    required this.anomaly,
    required this.timestamp,
    required this.anomalyReason,
    required this.light,
  });
}