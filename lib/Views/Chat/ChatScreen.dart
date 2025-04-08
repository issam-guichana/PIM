import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatScreen extends StatefulWidget {
  final int otherUserId;
  final String userName;

  const ChatScreen({super.key, required this.otherUserId, required this.userName});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final String baseUrl = "http://172.20.10.3:3000";
  List<dynamic> messages = [];
  bool isLoading = true;
  TextEditingController messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken') ?? '';

    final response = await http.get(
      Uri.parse('$baseUrl/chat/history?otherUserId=${widget.otherUserId}'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      setState(() {
        messages = jsonDecode(response.body);
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      print("Erreur: ${response.body}");
    }
  }

  Future<void> _sendMessage() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken') ?? '';
    String message = messageController.text.trim();

    if (message.isEmpty) return;

    final response = await http.post(
      Uri.parse('$baseUrl/chat/send'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        "receiverId": widget.otherUserId,
        "message": message,
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        messages.add({
          "message": message,
          "sentByMe": true,
        });
      });
      messageController.clear();
    } else {
      print("Erreur d'envoi: ${response.body}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.userName)),
      body: Column(
        children: [
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    reverse: true,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      var msg = messages[index];
                      bool sentByMe = msg['sentByMe'] ?? false;
                      return Align(
                        alignment: sentByMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          padding: EdgeInsets.all(10),
                          margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                          decoration: BoxDecoration(
                            color: sentByMe ? Colors.blueAccent : Colors.grey[300],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            msg['message'],
                            style: TextStyle(color: sentByMe ? Colors.white : Colors.black),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: InputDecoration(
                      hintText: "Écrire un message...",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.blueAccent),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
