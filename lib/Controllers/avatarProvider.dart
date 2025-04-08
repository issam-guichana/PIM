import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:record/record.dart';

class AvatarProvider extends ChangeNotifier {
  List<Map<String, String>> avatars = [];
  bool isLoading = false;
  String? errorMessage;

  late final IO.Socket _socket;
  final AudioRecorder record = AudioRecorder();
  String _transcription = '';
  String get transcription => _transcription;

  final String baseUrl = "http://10.0.2.2:3000";

  bool _isMounted = true;

  AvatarProvider() {
    _initSocket();
    _initMicrophone();
  }

  @override
  void dispose() {
    _isMounted = false;
    _socket.dispose();
    record.dispose();
    super.dispose();
  }

  void _initSocket() {
    _socket = IO.io(baseUrl, IO.OptionBuilder()
        .setTransports(['websocket'])
        .build());

    _socket.onConnect((_) {
      print("🧠 WebSocket connecté !");
    });

    _socket.on('transcription', (data) {
      print("📄 Transcription reçue : $data");
      _transcription = data.toString();
      notifyListeners();
    });

    _socket.onDisconnect((_) {
      print("🔌 WebSocket déconnecté");
    });
  }

  void _initMicrophone() async
   {
    bool micPermission = await record.hasPermission();
    if (!micPermission) {
      print("❌ Micro non autorisé !");
      return;
    }

    final stream = await record.startStream(
      const RecordConfig(encoder: AudioEncoder.pcm16bits, sampleRate: 16000),
    );

    stream.listen((Uint8List chunk) 
    {
      // Chaque chunk est envoyé vers le backend (NestJS → Deepgram)
      if (_socket.connected) {
        print("🎤 Envoi audio : ${chunk.length} bytes");
        _socket.emit('audio', chunk);
      }
    }, onDone: () {
      print("🎤 Capture terminée");
    }, onError: (e) {
      print("❌ Erreur micro : $e");
    });
  }
  Future<void> restartMicrophone() async 
  {
  await record.stop(); // Stoppe l’ancien stream
  await Future.delayed(Duration(milliseconds: 300));
  _initMicrophone(); // Redémarre proprement
  }


  Future<void> fetchAvatars() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final url = "$baseUrl/avatar/default";

    try {
      final response = await http.get(Uri.parse(url), headers: {"Accept": "application/json"});

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        avatars = List<Map<String, String>>.from(
          (data["avatars"] as List).map((avatar) => {
                "id": avatar["id"].toString(),
                "name": avatar["name"].toString(),
                "image": avatar["image"]?.toString() ?? "",
                "model": avatar["model"]?.toString() ?? "",
              }),
        );
      } else {
        errorMessage = "Erreur : ${response.body}";
      }
    } catch (error) {
      errorMessage = "Impossible de contacter le serveur.";
      print("❌ Erreur de connexion : $error");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
