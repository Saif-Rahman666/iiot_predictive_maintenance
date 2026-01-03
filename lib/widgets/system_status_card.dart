import 'package:flutter/material.dart';

class SystemStatusCard extends StatelessWidget {
  final bool connected;
  final bool modelLoaded;
  final bool anomalyDetected;

  const SystemStatusCard({
    super.key,
    required this.connected,
    required this.modelLoaded,
    required this.anomalyDetected,
  });

  @override
  Widget build(BuildContext context) {
    final bool healthy = connected && modelLoaded && !anomalyDetected;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'System Status',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Icon(
                  healthy ? Icons.check_circle : Icons.warning,
                  color: healthy ? Colors.green : Colors.red,
                  size: 28,
                ),
                const SizedBox(width: 8),
                Text(
                  healthy ? 'System Healthy' : 'System Degrading',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: healthy ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            Text('MQTT Connection: ${connected ? "Connected" : "Disconnected"}'),
            Text('ML Model: ${modelLoaded ? "Loaded" : "Not Loaded"}'),
          ],
        ),
      ),
    );
  }
}
