class Prediction {
  final int unit;
  final double healthIndex;
  final int? predictedRul;
  final String risk;
  final String timestamp;
  final int proxRaw; // Real I2C value
  final double lux;  // Real Light v

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
    unit: json['unit'],
    healthIndex: (json['health_index'] as num).toDouble(),
    predictedRul: (json['rul'] as num?)?.toInt() ?? 0, 
    risk: json['ir_status'] ?? 'CLEAR', 
    timestamp: DateTime.now().toIso8601String(),
    
    proxRaw: json['prox_raw'] ?? 0,
    lux: (json['lux'] as num?)?.toDouble() ?? 0.0,
  );
  }
}
