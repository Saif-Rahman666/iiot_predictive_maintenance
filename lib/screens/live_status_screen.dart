import 'package:flutter/material.dart';
import '../services/mqtt_service.dart';
import '../models/prediction.dart';

class LiveStatusScreen extends StatefulWidget {
  final MqttService mqttService;

  const LiveStatusScreen({super.key, required this.mqttService});

  @override
  State<LiveStatusScreen> createState() => _LiveStatusScreenState();
}

class _LiveStatusScreenState extends State<LiveStatusScreen> {
  Future<bool>? _connectionFuture;

  @override
  void initState() {
    super.initState();
    _connectionFuture = widget.mqttService.connect();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('IIoT Engine Health Monitor'),
        backgroundColor: Colors.blueGrey[900],
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<bool>(
        future: _connectionFuture,
        builder: (context, connSnapshot) {
          if (connSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (connSnapshot.data == false) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 60),
                  const SizedBox(height: 10),
                  Text("❌ Cannot reach Pi at ${widget.mqttService.broker}"),
                  const Text("Check if Mosquitto and the IP are correct."),
                ],
              ),
            );
          }

          return StreamBuilder<Map<String, dynamic>>(
            stream: widget.mqttService.subscribePrediction(1),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 15),
                      Text("Connected! Waiting for ML data from Pi..."),
                    ],
                  ),
                );
              }

              final prediction = Prediction.fromJson(snapshot.data!);

              return Padding(
                padding: const EdgeInsets.all(20),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Engine Unit: ${prediction.unit}', 
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            const Icon(Icons.settings_input_component, color: Colors.blueGrey),
                          ],
                        ),
                        const Divider(height: 30),
                        _buildStatusRow('Health Index', "${(prediction.healthIndex * 100).toStringAsFixed(1)}%"),
                        _buildStatusRow('Predicted RUL', '${prediction.predictedRul ?? "Calculating..."} Cycles'),
                        const SizedBox(height: 25),
                        _buildRiskBadge(prediction.risk),
                        const SizedBox(height: 20),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Text('Last Scan: ${prediction.timestamp.split('T').last.substring(0, 8)}', 
                              style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStatusRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16, color: Colors.black54)),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildRiskBadge(String risk) {
    Color color = Colors.green;
    if (risk == 'CRITICAL') color = Colors.red;
    if (risk == 'HIGH') color = Colors.orange;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color, width: 2),
      ),
      child: Center(
        child: Text(
          'RISK STATUS: $risk',
          style: TextStyle(fontSize: 16, color: color, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}