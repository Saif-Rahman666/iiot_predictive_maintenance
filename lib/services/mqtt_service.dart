import 'dart:convert';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_browser_client.dart';

class MqttService {
  final String broker;
  final String clientId;
  late MqttBrowserClient client;

  MqttService({required this.broker, required this.clientId}) {
    final String uniqueId = '${clientId}_${DateTime.now().millisecondsSinceEpoch}';
    client = MqttBrowserClient('ws://$broker', uniqueId);
    client.port = 9001;
    client.keepAlivePeriod = 20;
    client.websocketProtocols = MqttClientConstants.protocolsSingleDefault;

    client.onDisconnected = () => print("❌ MQTT: Disconnected");
    client.onConnected = () => print("✅ MQTT: Connected to Pi");
  }

  Future<bool> connect() async {
    final connMessage = MqttConnectMessage()
        .withClientIdentifier(client.clientIdentifier)
        .startClean()
        .withWillQos(MqttQos.atMostOnce);
    client.connectionMessage = connMessage;

    try {
      await client.connect();
      return client.connectionStatus?.state == MqttConnectionState.connected;
    } catch (e) {
      print("❌ MQTT: Connection failed: $e");
      return false;
    }
  }

  Stream<Map<String, dynamic>> subscribeStatus(int unitId) {
    // We listen to the topic where the AI publishes the "Fused" data
    final topic = 'engine/$unitId/status';

    if (client.connectionStatus?.state != MqttConnectionState.connected) {
      return Stream.value({"error": "Not connected"});
    }

    client.subscribe(topic, MqttQos.atMostOnce);

    return client.updates!.map((List<MqttReceivedMessage<MqttMessage>> events) {
      final MqttPublishMessage recMess = events[0].payload as MqttPublishMessage;
      final payload = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      
      try {
        final Map<String, dynamic> data = json.decode(payload);
        
        // FIXED: Using ?? (null-coalescing) to provide default values prevents TypeError
        return {
          'unit': data['unit'] ?? 1,
          'health_index': (data['health_index'] ?? 0.0).toDouble(),
          'predicted_rul': data['rul'] ?? 0,
          'prox_raw': data['prox_raw'] ?? 0, // Default to 0 if null
          'lux': (data['lux'] ?? 0.0).toDouble(),
          'ir_status': data['ir_status'] ?? "Clear",
          'risk': (data['health_index'] ?? 1.0) < 0.3 ? "CRITICAL" : "STABLE",
        };
      } catch (e) {
        return {"error": "Parse Error"};
      }
    });
  }
}