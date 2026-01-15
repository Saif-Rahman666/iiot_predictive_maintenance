import 'package:flutter/material.dart';
import '../models/prediction.dart';


class AnomalyExplanationCard extends StatelessWidget {
  final Prediction data;

  const AnomalyExplanationCard({super.key, required this.data});

  List<String> _buildReasons() {
    final reasons = <String>[];

    // Check for Physical Blockage (IR Sensor)
    if (data.risk == "CRITICAL" && data.proxRaw > 3000) {
      reasons.add('Physical Obstruction Detected (IR Sensor Blocked)');
    }

    // Check for NASA Data degradation
    if (data.healthIndex < 0.4) {
      reasons.add('Critical Health Index Decline (Edge-AI Prediction)');
    }

    if (data.predictedRul != null && data.predictedRul! < 20) {
      reasons.add('Remaining Useful Life is critically low (${data.predictedRul} cycles)');
    }
    if (data.lux < 1.0) {
      reasons.add('Ambient Light Critical: Potential Engine Room Lighting Failure');
    }

    if (reasons.isEmpty) {
      reasons.add('Unusual sensor pattern detected by the system');
    }

    return reasons;
  }

  @override
  Widget build(BuildContext context) {
    if (data.risk != "CRITICAL" && (data.predictedRul == null || data.predictedRul! > 30)) {
      return const SizedBox.shrink();
    }

    final reasons = _buildReasons();

    return Card(
      color: Colors.red.shade900.withOpacity(0.8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '⚠️ ANOMALY DETECTED',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 12),
            ...reasons.map((reason) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text('• $reason', style: const TextStyle(color: Colors.white70, fontSize: 15)),
            )),
          ],
        ),
      ),
    );
  }
}