import 'dart:convert';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_browser_client.dart';

class MqttService {
  final String broker;
  final String clientId;
  final MqttBrowserClient client; 

  MqttService({required this.broker, required this.clientId}) 
      : client = MqttBrowserClient('ws://$broker', clientId) {
    
    // Configured for Port 9001 WebSockets on the Raspberry Pi
    client.port = 9001; 
    client.keepAlivePeriod = 30;
    client.websocketProtocols = MqttClientConstants.protocolsSingleDefault;
    
    client.onDisconnected = () => print("❌ MQTT disconnected");
    client.onConnected = () => print("✅ MQTT connected to Pi");
  }

  Future<bool> connect() async {
    final connMessage = MqttConnectMessage()
        .withClientIdentifier(clientId)
        .startClean()
        .withWillQos(MqttQos.atMostOnce);
    client.connectionMessage = connMessage;

    try {
      print("📡 Attempting to connect to Pi at $broker...");
      await client.connect();
      return client.connectionStatus?.state == MqttConnectionState.connected;
    } catch (e) {
      print("❌ Connection failed: $e");
      return false;
    }
  }

  Stream<Map<String, dynamic>> subscribePrediction(int unitId) {
    final topic = 'engine/$unitId/prediction';
    
    if (client.connectionStatus?.state != MqttConnectionState.connected) {
      return const Stream.empty();
    }

    client.subscribe(topic, MqttQos.atMostOnce);

    return client.updates!
        .where((events) => events[0].topic == topic)
        .map((events) {
      final MqttPublishMessage recMess = events[0].payload as MqttPublishMessage;
      final payload = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      return json.decode(payload) as Map<String, dynamic>;
    });
  }
}