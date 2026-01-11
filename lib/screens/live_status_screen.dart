import 'package:flutter/material.dart';
import '../services/mqtt_service.dart';
import '../models/prediction.dart';
import '../widgets/realtime_line_chart.dart'; // Import your graph widget

class LiveStatusScreen extends StatefulWidget {
  final MqttService mqttService;
  const LiveStatusScreen({super.key, required this.mqttService});

  @override
  State<LiveStatusScreen> createState() => _LiveStatusScreenState();
}

class _LiveStatusScreenState extends State<LiveStatusScreen> {
  Future<bool>? _connectionFuture;
  final List<double> _healthHistory = [];
  static const int maxPoints = 30;

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
                ],
              ),
            );
          }

          return StreamBuilder<Map<String, dynamic>>(
            stream: widget.mqttService.subscribeStatus(1), // Ensure this matches Pi topic
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final prediction = Prediction.fromJson(snapshot.data!);
              
              // Logic: Red if proximity > 3000
              bool isBlocked = prediction.proxRaw > 3000;

              // Update Graph History
              _healthHistory.add(prediction.healthIndex);
              if (_healthHistory.length > maxPoints) _healthHistory.removeAt(0);

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // --- YOUR ORIGINAL CARD VIEW ---
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Engine Unit: ${prediction.unit}', 
                                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                Icon(Icons.settings_input_component, 
                                     color: isBlocked ? Colors.red : Colors.blueGrey),
                              ],
                            ),
                            const Divider(height: 30),
                            _buildStatusRow('Health Index', "${(prediction.healthIndex * 100).toStringAsFixed(1)}%"),
                            _buildStatusRow('Predicted RUL', '${prediction.predictedRul ?? "..."} Cycles'),
                            _buildStatusRow('Proximity (I2C)', '${prediction.proxRaw}'), // NEW
                            _buildStatusRow('Ambient Light', '${prediction.lux.toStringAsFixed(1)} Lux'), // NEW
                            const SizedBox(height: 25),
                            _buildRiskBadge(prediction.risk),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 20),

                    // --- NEW ADDITIONAL GRAPH ---
                    RealtimeLineChart(
                      values: List.from(_healthHistory),
                      title: 'Real-time Health Trend',
                      color: isBlocked ? Colors.red : Colors.blue,
                    ),
                  ],
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
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16, color: Colors.white)),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildRiskBadge(String risk) {
    Color color = (risk == 'CRITICAL') ? Colors.red : Colors.green;
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