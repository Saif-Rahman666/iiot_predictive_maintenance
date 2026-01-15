import 'package:flutter/material.dart';
import '../models/prediction.dart';
import '../widgets/sensor_card.dart';
import '../widgets/status_badge.dart';
import '../services/sensor_data_service.dart';
import '../widgets/system_status_card.dart';
import '../widgets/realtime_line_chart.dart';
import '../widgets/anomaly_explanation_card.dart';
import '../screens/live_status_screen.dart';
import '../services/mqtt_service.dart';

class DashboardScreen extends StatefulWidget {
  // Add the service as a required parameter
  final MqttService mqttService;

  const DashboardScreen({super.key, required this.mqttService});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Future<bool>? _connectionFuture;
  final List<double> _healthHistory = [];
  final List<double> _rulHistory = [];

  static const int maxPoints = 30;

  @override
  void initState() {
    super.initState();
    _connectionFuture = widget.mqttService.connect();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('System Dashboard')),
      body: FutureBuilder<bool>(
        future: _connectionFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: Text('Waiting for data...'));
          }
          if (snapshot.data == false) {
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
            stream: widget.mqttService.subscribeStatus(1),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: Text('Listening for Edge Data...'));
              }

              final prediction = Prediction.fromJson(snapshot.data!);
              _healthHistory.add(prediction.healthIndex);
              if (prediction.predictedRul != null) {
                _rulHistory.add(prediction.predictedRul!.toDouble());
              }

              if (_healthHistory.length > maxPoints) {
                _healthHistory.removeAt(0);
                _rulHistory.removeAt(0);
              }

              return Padding(
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      StatusBadge(
                        rul: (prediction.predictedRul ?? 0).toDouble(),
                        anomalyDetected: prediction.risk == "CRITICAL",
                      ),
                      const SizedBox(height: 12),

                      ElevatedButton.icon(
                        icon: const Icon(Icons.show_chart),
                        label: const Text('Open Live Status'),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => LiveStatusScreen(
                                  mqttService: widget.mqttService), // Fixed!
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 16),
                      AnomalyExplanationCard(data: prediction),
                      const SizedBox(height: 16),
                      SystemStatusCard(
                        connected: true, // later from MQTT
                        modelLoaded: true, // later from TFLite
                        anomalyDetected: prediction.risk == "CRITICAL",
                      ),
                      const SizedBox(height: 16),
                      const SizedBox(height: 16),
                      RealtimeLineChart(
                        values: List.from(_healthHistory),
                        title: 'Health Index Trend (%)',
                        color: prediction.risk == "CRITICAL"
                            ? Colors.red
                            : Colors.green,
                      ),
                      const SizedBox(height: 16),
                      RealtimeLineChart(
                        values: _rulHistory,
                        title: 'Remaining Useful Life Trend (hrs)',
                        color: Colors.blue,
                      ),
                      const SizedBox(height: 16),
                      //live sensor data cards
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        children: [
                          SensorCard(
                            title: 'Proximity',
                            value: '${prediction.proxRaw}',
                            icon: Icons.sensors,
                          ),
                          SensorCard(
                            title: 'Light',
                            value: '${prediction.lux.toStringAsFixed(1)} lux',
                            icon: Icons.light_mode,
                            color: prediction.lux < 1.0 ? Colors.red : Colors.blue,
                          ),
                          SensorCard(
                            title: 'Machine Health Index',
                            value:
                                '${(prediction.healthIndex * 100).toStringAsFixed(1)}%',
                            icon: Icons.favorite,
                          ),
                          SensorCard(
                            title: 'Cycles to Failure',
                            value: '${prediction.predictedRul ?? "..."}',
                            icon: Icons.autorenew,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => LiveStatusScreen(
                                  mqttService: widget.mqttService)),
                        ),
                        child: const Text("View Detailed Real-time Graphs"),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
