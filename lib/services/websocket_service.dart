import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  IO.Socket? socket;

  void connect() {
    socket = IO.io('ws://192.168.1.162:3000', <String, dynamic>{  // ⚠️ Mets l'IP correcte ici
      'transports': ['websocket'],
      'autoConnect': true,
    });

    socket!.onConnect((_) {
      print("✅ Connecté au serveur WebSocket");
    });

    socket!.onDisconnect((_) {
      print("❌ Déconnecté du serveur WebSocket, tentative de reconnexion...");
      reconnect();
    });
  }

  void reconnect() {
    Future.delayed(Duration(seconds: 3), () {
      print("🔄 Tentative de reconnexion...");
      connect();
    });
  }

  void sendHealthData(Map<String, dynamic> data) {
    if (socket != null && socket!.connected) {
      socket!.emit('healthData', data);
      print("📤 Données envoyées : $data");
    } else {
      print("⚠ WebSocket non connecté. Tentative de reconnexion...");
      reconnect();
    }
  }

  void listenForHealthUpdates(Function(Map<String, dynamic>) onDataReceived) {
    socket!.on('healthDataUpdate', (data) {
      print("📥 Données mises à jour reçues : $data");
      onDataReceived(data);
    });

    socket!.on('error', (data) {
      print("⚠ Erreur WebSocket : $data");
    });
  }
}
