import 'package:flutter/material.dart';
import '../models/sensor_data.dart';
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
  final SensorDataService _service = SensorDataService();
  final List<double> _tempHistory = [];
  final List<double> _rulHistory = [];

  static const int maxPoints = 30;

  @override
  void initState() {
    super.initState();
    _service.start();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('System Dashboard')),
      body: StreamBuilder<SensorData>(
        stream: _service.stream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: Text('Waiting for data...'));
          }

          final data = snapshot.data!;
          _tempHistory.add(data.temperature);
          _rulHistory.add(data.rul);

          if (_tempHistory.length > maxPoints) {
            _tempHistory.removeAt(0);
            _rulHistory.removeAt(0);
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  StatusBadge(
                    rul: data.rul,
                    anomalyDetected: data.anomaly,
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
                  AnomalyExplanationCard(data: data),
                  const SizedBox(height: 16),
                  SystemStatusCard(
                    connected: true, // later from MQTT
                    modelLoaded: true, // later from TFLite
                    anomalyDetected: data.anomaly,
                  ),
                  const SizedBox(height: 16),
                  const SizedBox(height: 16),
                  RealtimeLineChart(
                    values: _tempHistory,
                    title: 'Temperature Trend (°C)',
                    color: Colors.orange,
                  ),
                  const SizedBox(height: 16),
                  RealtimeLineChart(
                    values: _rulHistory,
                    title: 'Remaining Useful Life Trend (hrs)',
                    color: Colors.blue,
                  ),
                  SensorCard(
                    title: 'Temperature',
                    value: '${data.temperature.toStringAsFixed(1)} °C',
                    icon: Icons.thermostat,
                  ),
                  SensorCard(
                    title: 'Proximity',
                    value: data.proximity.toStringAsFixed(0),
                    icon: Icons.sensors,
                  ),
                  SensorCard(
                    title: 'Light',
                    value: '${data.light.toStringAsFixed(1)} lux',
                    icon: Icons.light_mode,
                  ),
                  SensorCard(
                    title: 'RUL',
                    value: '${data.rul.toStringAsFixed(0)} hrs',
                    icon: Icons.timelapse,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }
}
