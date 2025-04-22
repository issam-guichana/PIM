import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:tesst1/Controllers/AuthProviders.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class Message {
  final String senderId;
  final String receiverId;
  final String content;
  final DateTime timestamp;
  bool read;

  Message({
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.timestamp,
    this.read = false,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      senderId: json['senderId'] ?? '',
      receiverId: json['receiverId'] ?? '',
      content: json['content'] ?? '',
      timestamp:
          DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      read: json['read'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'read': read,
    };
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late IO.Socket socket;
  List<Message> messages = [];
  final TextEditingController _messageController = TextEditingController();
  User? receiver;
  bool _isLoading = true;

  // Local notifications plugin
  late FlutterLocalNotificationsPlugin _localNotifications;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _initializeChat();
  }

  void _initializeNotifications() {
    _localNotifications = FlutterLocalNotificationsPlugin();
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    _localNotifications.initialize(settings);
  }

  Future<void> _showNotification(Message msg) async {
    // Show the notification asynchronously without blocking the UI
    Future.delayed(Duration.zero, () async {
      const androidDetails = AndroidNotificationDetails(
        'chat_channel',
        'Chat Messages',
        channelDescription: 'Channel for chat message notifications',
        importance: Importance.max,
        priority: Priority.high,
      );
      const platformDetails = NotificationDetails(android: androidDetails);

      await _localNotifications.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        'New message from ${receiver?.name ?? 'Unknown'}',
        msg.content,
        platformDetails,
        payload: jsonEncode(msg.toJson()),
      );
    });
  }

  Future<void> _initializeChat() async {
    final authProvider = Provider.of<AuthProviders>(context, listen: false);

    if (authProvider.user == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    if (authProvider.user!.relatedUsers.isEmpty) {
      await authProvider.fetchRelatedUsers();
    }

    setState(() {
      if (authProvider.user!.relatedUsers.isNotEmpty) {
        receiver = authProvider.user!.relatedUsers.first;
        _fetchMessages();
        _connectSocket();
      }
      _isLoading = false;
    });
  }

  void _connectSocket() {
    final authProvider = Provider.of<AuthProviders>(context, listen: false);
    socket = IO.io('http://192.168.1.12:3000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'query': {'userId': authProvider.user!.id},
    });

    socket.connect();

    socket.on('receiveMessage', (data) {
      final msg = Message.fromJson(data);
      setState(() {
        messages.add(msg);
      });
      // Show local notification asynchronously
      _showNotification(msg);
      socket.emit('markAsRead', {
        'senderId': authProvider.user!.id,
        'receiverId': receiver!.id,
      });
    });

    socket.on('messageSent', (data) {
      setState(() {
        messages.add(Message.fromJson(data));
      });
    });

    socket.on('messagesRead', (data) {
      setState(() {
        messages
            .where((msg) => msg.senderId == data['receiverId'])
            .forEach((msg) {
          msg.read = true;
        });
      });
    });
  }

  Future<void> _fetchMessages() async {
    final authProvider = Provider.of<AuthProviders>(context, listen: false);
    final response = await http.get(
      Uri.parse(
          'http://192.168.1.12:3000/chat/messages/${authProvider.user!.id}/${receiver!.id}'),
      headers: {'Authorization': 'Bearer ${authProvider.token}'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        messages = data.map((e) => Message.fromJson(e)).toList();
      });
    }
  }

  void _sendMessage() {
    if (_messageController.text.isEmpty || receiver == null) return;

    final authProvider = Provider.of<AuthProviders>(context, listen: false);
    final message = {
      'senderId': authProvider.user!.id,
      'receiverId': receiver!.id,
      'content': _messageController.text,
    };

    socket.emit('sendMessage', message);
    _messageController.clear();
  }

  @override
  void dispose() {
    socket.disconnect();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProviders>(context);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text("Chat")),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (authProvider.user == null || receiver == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Chat")),
        body: const Center(child: Text("No related users found.")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Chat with ${receiver!.name}"),
        backgroundColor: const Color(0xFF723D92),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final isMe = message.senderId ==
                    Provider.of<AuthProviders>(context, listen: false).user!.id;
                return Align(
                  alignment:
                      isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isMe ? const Color(0xFF723D92) : Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: isMe
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        Text(
                          message.content,
                          style: TextStyle(
                            color: isMe ? Colors.white : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              message.timestamp.toString().substring(11, 16),
                              style: TextStyle(
                                fontSize: 10,
                                color: isMe ? Colors.white70 : Colors.black54,
                              ),
                            ),
                            if (isMe && message.read)
                              const Icon(Icons.check,
                                  size: 14, color: Colors.white70),
                          ],
                        ),
                      ],
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
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: "Type a message...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Color(0xFF723D92)),
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
