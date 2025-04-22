import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:version1/Views/AsistanceVocal/VoiceRecordingPage.dart';
import 'package:web_socket_channel/io.dart'; // Importez le package pour WebSocket
import 'package:version1/Views/Patient/CustomBottomNavBar.dart';
import 'package:version1/Views/Avatar/avatar_app.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePagePatient extends StatefulWidget {
  const HomePagePatient({Key? key}) : super(key: key);

  @override
  _HomePagePatientState createState() => _HomePagePatientState();
}

class _HomePagePatientState extends State<HomePagePatient> {
  int _selectedIndex = 0;
  late IOWebSocketChannel _channel;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _startVoiceAssistance(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    _initWebSocket();

    Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => VoiceRecordingPage()),
);

  }

  void _initWebSocket() {
    _channel = IOWebSocketChannel.connect(
      Uri.parse('wss://api.deepgram.com/v1/listen'),
      headers: {
        'Authorization': 'Token a98ac2b8816736333008d8f5d0a5e5151ead5aa4',
        'Content-Type': 'application/json'
      },
    );

    _channel.stream.listen((data) {
      var response = json.decode(data);
      String transcript = response['channel']['alternatives'][0]['transcript'];
      print('Transcription: $transcript'); // Affichez la transcription dans le terminal
    }, onError: (error) {
      print('WebSocket error: $error');
    }, onDone: () {
      print('WebSocket closed');
    });
  }

  void _openChat() {
    // Chat à implémenter
  }

  @override
  void dispose() {
    _channel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      floatingActionButton: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFFB041F0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              offset: const Offset(0, 4),
              blurRadius: 8,
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () => _startVoiceAssistance(context),
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.mic, color: Colors.white, size: 30),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: CustomBottomNavBarPatient(
        selectedIndex: _selectedIndex,
        onItemSelected: _onItemTapped,
      ),
    );
  }
}