class Prediction {
  final int unit;
  final double healthIndex;
  final int? predictedRul;
  final String risk;
  final String timestamp;

  Prediction({
    required this.unit,
    required this.healthIndex,
    required this.predictedRul,
    required this.risk,
    required this.timestamp,
  });

  factory Prediction.fromJson(Map<String, dynamic> json) {
    return Prediction(
      unit: json['unit'],
      healthIndex: (json['health_index'] as num).toDouble(),
      predictedRul: json['predicted_rul'],
      risk: json['risk'],
      timestamp: json['timestamp'],
    );
  }
}
