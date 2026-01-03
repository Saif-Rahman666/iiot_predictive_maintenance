import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final double rul;
  final bool anomalyDetected;

  const StatusBadge({
    super.key,
    required this.rul,
    required this.anomalyDetected,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: anomalyDetected ? Colors.red.shade100 : Colors.green.shade100,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Remaining Useful Life',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  '$rul hours',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            Icon(
              anomalyDetected ? Icons.warning : Icons.check_circle,
              color: anomalyDetected ? Colors.red : Colors.green,
              size: 32,
            ),
          ],
        ),
      ),
    );
  }
}
