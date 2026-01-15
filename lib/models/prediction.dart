class Prediction {
  final int unit;
  final double healthIndex;
  final int? predictedRul;
  final String risk;
  final String timestamp;
  final int proxRaw; 
  final double lux;  

  Prediction({
    required this.unit,
    required this.healthIndex,
    required this.predictedRul,
    required this.risk,
    required this.timestamp,
    required this.proxRaw,
    required this.lux,
  });

  factory Prediction.fromJson(Map<String, dynamic> json) {
    return Prediction(
      unit: json['unit'] ?? 1,
      healthIndex: (json['health_index'] as num?)?.toDouble() ?? 0.0,
      predictedRul: json['rul'] as int?,
      risk: json['ir_status'] ?? 'CLEAR', 
      timestamp: DateTime.now().toIso8601String(),
      proxRaw: json['prox_raw'] ?? 0,
      lux: (json['lux'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
