import 'package:flutter/material.dart';
import 'state/app_state.dart';
import 'screens/dashboard_screen.dart';
import 'dart:async';
import 'models/sensor_data.dart';

final appState = AppState();

void main() {
  startTestFeed();
  runApp(const IIoTApp());
}

void startTestFeed() {
  Timer.periodic(const Duration(seconds: 2), (timer) {
    appState.update(
      SensorData(
        temperature: 20 + timer.tick % 5,
        proximity: 300.0 + timer.tick,
        light: 100 + timer.tick * 2,
        rul: 100 - timer.tick.toDouble(),
        anomaly: timer.tick % 7 == 0,
        timestamp: DateTime.now(),
        anomalyReason: timer.tick % 7 == 0
            ? 'RUL dropping rapidly with abnormal temperature pattern'
            : 'All parameters within normal range',
      ),
    );
  });
}

class IIoTApp extends StatelessWidget {
  const IIoTApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IIoT Predictive Maintenance',
      theme: ThemeData.dark(),
      home: const DashboardScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
