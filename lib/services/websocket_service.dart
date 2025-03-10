import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  IO.Socket? socket;

  // Tentatives de reconnexion limitées
  int reconnectAttempts = 0;
  final int maxReconnectAttempts = 5;

  void connect() {
    socket = IO.io('ws://192.168.1.124:3000', <String, dynamic>{  // ⚠️ Mets l'IP correcte ici
      'transports': ['websocket'],
      'autoConnect': true,
    });

    socket!.onConnect((_) {
      print("✅ Connecté au serveur WebSocket");
      reconnectAttempts = 0;  // Réinitialiser les tentatives de reconnexion après une connexion réussie
    });

    socket!.onDisconnect((_) {
      print("❌ Déconnecté du serveur WebSocket, tentative de reconnexion...");
      reconnect();
    });
    
    socket!.onError((error) {
      print("⚠ Erreur WebSocket: $error");
    });
  }

  // Limitation du nombre de tentatives de reconnexion
  void reconnect() {
    if (reconnectAttempts < maxReconnectAttempts) {
      Future.delayed(Duration(seconds: 3), () {
        print("🔄 Tentative de reconnexion...");
        connect();
        reconnectAttempts++;
      });
    } else {
      print("⚠️ Échec de la reconnexion après $maxReconnectAttempts tentatives.");
    }
  }

  // Envoie les données de santé via WebSocket
  void sendHealthData(Map<String, dynamic> data) {
    if (socket != null && socket!.connected) {
      socket!.emit('healthData', data);
      print("📤 Données envoyées : $data");
    } else {
      print("⚠ WebSocket non connecté. Tentative de reconnexion...");
      reconnect();
    }
  }

  // Écoute les mises à jour de données de santé
  void listenForHealthUpdates(Function(Map<String, dynamic>) onDataReceived) {
    if (socket != null) {
      socket!.on('healthDataUpdate', (data) {
        print("📥 Données mises à jour reçues : $data");
        onDataReceived(data);
      });

      socket!.on('error', (data) {
        print("⚠ Erreur WebSocket : $data");
      });
    }
  }

  // Demande l'historique des données de santé
  void requestHealthHistory(String userId, int days) {
    if (socket != null && socket!.connected) {
      socket!.emit('requestHealthHistory', {'userId': userId, 'days': days});
      print("📤 Demande d'historique : $userId - $days jours");
    } else {
      print("⚠ WebSocket non connecté. Tentative de reconnexion...");
      reconnect();
    }
  }

  // Écoute la réponse de l'historique des données de santé
  void listenForHealthUpdate(Function(List<dynamic>) onDataReceived) {
    if (socket != null) {
      socket!.on('healthHistoryResponse', (data) {
        print("📥 Historique reçu : $data");
        onDataReceived(data);
      });
    }
  }

  // Déconnecte proprement
  void disconnect() {
    if (socket != null && socket!.connected) {
      socket!.disconnect();
      print("❌ Déconnexion du serveur WebSocket");
    }
  }
}
