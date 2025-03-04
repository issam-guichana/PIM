import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  IO.Socket? socket;

  void connect() {
    socket = IO.io('ws://192.168.137.27:3000', <String, dynamic>{  // ⚠️ Mets l'IP correcte ici
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

   void requestHealthHistory(String userId, int days) {
    if (socket != null && socket!.connected) {
      socket!.emit('requestHealthHistory', {'userId': userId, 'days': days});
      print("📤 Demande d'historique : $userId - $days jours");
    }
  }

  void listenForHealthUpdate(Function(List<dynamic>) onDataReceived) {
    socket!.on('healthHistoryResponse', (data) {
      print("📥 Historique reçu : $data");
      onDataReceived(data);
    });
  }
}
