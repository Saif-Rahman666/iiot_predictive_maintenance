import 'package:flutter/material.dart';
import 'services/mqtt_service.dart';
import 'screens/live_status_screen.dart';
import 'screens/dashboard_screen.dart';

void main() {
  final mqttService = MqttService(
    // MQTT CONFIGURATION
    broker: '172.20.10.5',
    //broker: '192.168.0.202',
    clientId: 'flutter_web_${DateTime.now().millisecondsSinceEpoch}',
  );

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    // THEME CONFIGURATION
    themeMode: ThemeMode.dark, // Force Dark Mode
    darkTheme: ThemeData(
      useMaterial3: true, // Ensures you're using the latest UI standards
      brightness: Brightness.dark,
      colorSchemeSeed: Colors.blueGrey,
      scaffoldBackgroundColor: const Color(0xFF0F172A),

      // FIXED: Changed CardTheme to CardThemeData
      cardTheme: CardThemeData(
        color: const Color(0xFF1E293B),
        elevation: 4,
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1E293B),
        centerTitle: true,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
    home: DashboardScreen(mqttService: mqttService),
  ));
}
