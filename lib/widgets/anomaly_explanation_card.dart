import 'package:flutter/material.dart';
import '../models/sensor_data.dart';

class AnomalyExplanationCard extends StatelessWidget {
  final SensorData data;

  const AnomalyExplanationCard({
    super.key,
    required this.data,
  });

  List<String> _buildReasons() {
    final reasons = <String>[];

    if (data.temperature > 20) {
      reasons.add(
          'High temperature detected (${data.temperature.toStringAsFixed(1)} °C)');
    }

    if (data.rul < 20) {
      reasons.add(
          'Remaining Useful Life is critically low (${data.rul.toStringAsFixed(0)} hrs)');
    }

    if (data.proximity > 500) {
      reasons.add('Abnormal proximity sensor readings');
    }

    if (reasons.isEmpty) {
      reasons.add('Unusual sensor pattern detected by the system');
    }

    return reasons;
  }

  @override
  Widget build(BuildContext context) {
    if (!data.anomaly) return const SizedBox.shrink();

    final reasons = _buildReasons();

    return Card(
      color: Colors.red.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '⚠ Anomaly Explanation',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 12),
            ...reasons.map(
              (reason) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(fontSize: 16)),
                    Expanded(
                      child: Text(
                        reason,
                        style: const TextStyle(
                            fontSize: 15, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
