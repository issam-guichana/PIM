import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  IO.Socket? socket;

  void connect() {
    socket = IO.io('http://192.168.137.51:3000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket!.onConnect((_) {
      print("Connecté au serveur WebSocket");
    });

    socket!.connect();
  }

  void sendHealthData(Map<String, dynamic> data) {
    if (socket != null && socket!.connected) {
      socket!.emit('healthData', data);
      print("Données envoyées : $data");
    } else {
      print("WebSocket non connecté");
    }
  }
}
