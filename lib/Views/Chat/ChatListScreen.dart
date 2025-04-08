import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:tesst1/Views/Chat/ChatScreen.dart' show ChatScreen;

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final String baseUrl = "http://172.20.10.3:3000";
  List<dynamic> conversations = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken') ?? '';
    
    final response = await http.get(
      Uri.parse('$baseUrl/chat/conversations'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      setState(() {
        conversations = jsonDecode(response.body);
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      print("Erreur: ${response.body}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Conversations')),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: conversations.length,
              itemBuilder: (context, index) {
                var convo = conversations[index];
                return ListTile(
                  leading: CircleAvatar(child: Text(convo['name'][0])),
                  title: Text(convo['name']),
                  subtitle: Text(convo['lastMessage']),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ChatScreen(otherUserId: convo['id'], userName: convo['name']),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
