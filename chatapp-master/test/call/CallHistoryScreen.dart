import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:tesst1/Controllers/AuthProviders.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:tesst1/views/call/CallScreen.dart';

class Call {
  final String id;
  final String callerId;
  final String receiverId;
  final String type;
  final String status;
  final DateTime timestamp;
  final int? duration;

  Call({
    required this.id,
    required this.callerId,
    required this.receiverId,
    required this.type,
    required this.status,
    required this.timestamp,
    this.duration,
  });

  factory Call.fromJson(Map<String, dynamic> json) {
    return Call(
      id: json['_id'],
      callerId: json['callerId'],
      receiverId: json['receiverId'],
      type: json['type'],
      status: json['status'],
      timestamp: DateTime.parse(json['timestamp']),
      duration: json['duration'],
    );
  }
}

class CallHistoryScreen extends StatefulWidget {
  const CallHistoryScreen({super.key});

  @override
  _CallHistoryScreenState createState() => _CallHistoryScreenState();
}

class _CallHistoryScreenState extends State<CallHistoryScreen> {
  List<Call> callHistory = [];
  late IO.Socket socket;

  @override
  void initState() {
    super.initState();
    _fetchCallHistory();
    _connectSocket();
  }

  void _connectSocket() {
    final authProvider = Provider.of<AuthProviders>(context, listen: false);
    socket = IO.io('http://192.168.42.253:3000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'query': {'userId': authProvider.user!.id},
    });

    socket.connect();

    socket.on('incomingCall', (data) {
      _showIncomingCallDialog(data);
    });

    socket.on('callAnswered', (data) {
      if (data['status'] == 'accepted') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CallScreen(
              callId: data['callId'],
              callerId: data['callerId'],
              receiverId: data['receiverId'],
              type: data['type'],
              sdp: data['sdp'], // Pass the SDP answer to CallScreen
              isCaller: true,
            ),
          ),
        );
      }
    });
  }

  Future<void> _fetchCallHistory() async {
    final authProvider = Provider.of<AuthProviders>(context, listen: false);
    final response = await http.get(
      Uri.parse(
          'http://192.168.42.253:3000/call/history/${authProvider.user!.id}'),
      headers: {'Authorization': 'Bearer ${authProvider.token}'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        callHistory = data.map((e) => Call.fromJson(e)).toList();
      });
    }
  }

  void _startCall(String type) {
    final authProvider = Provider.of<AuthProviders>(context, listen: false);
    if (authProvider.user!.relatedUsers.isEmpty) return;

    final receiver = authProvider.user!.relatedUsers.first;
    // The actual SDP will be sent from CallScreen after WebRTC setup
    socket.emit('startCall', {
      'callerId': authProvider.user!.id,
      'receiverId': receiver.id,
      'type': type,
      'sdp': '', // SDP will be updated in CallScreen
    });

    // Navigate to CallScreen immediately to start WebRTC setup
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CallScreen(
          callId: DateTime.now()
              .millisecondsSinceEpoch
              .toString(), // Temporary callId (should come from backend)
          callerId: authProvider.user!.id,
          receiverId: receiver.id,
          type: type,
          sdp: '', // Not needed for caller initially
          isCaller: true,
        ),
      ),
    );
  }

  void _showIncomingCallDialog(Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Incoming ${data['type']} Call'),
        content: Text('From: ${data['callerId']}'),
        actions: [
          TextButton(
            onPressed: () {
              socket.emit('answerCall', {
                'callId': data['callId'],
                'callerId': data['callerId'],
                'receiverId': data['receiverId'],
                'accepted': false,
              });
              Navigator.pop(context);
            },
            child: const Text('Reject'),
          ),
          TextButton(
            onPressed: () {
              // Navigate to CallScreen to handle the call (callee)
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CallScreen(
                    callId: data['callId'],
                    callerId: data['callerId'],
                    receiverId: data['receiverId'],
                    type: data['type'],
                    sdp: data['sdp'], // Pass the SDP offer to CallScreen
                    isCaller: false,
                  ),
                ),
              );
            },
            child: const Text('Accept'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    socket.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Call History"),
        backgroundColor: const Color(0xFF723D92),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _startCall('voice'),
                  icon: const Icon(Icons.phone),
                  label: const Text("Voice Call"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF723D92),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _startCall('video'),
                  icon: const Icon(Icons.videocam),
                  label: const Text("Video Call"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF723D92),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: callHistory.length,
              itemBuilder: (context, index) {
                final call = callHistory[index];
                return ListTile(
                  title: Text("${call.type} Call - ${call.status}"),
                  subtitle: Text(
                      "With: ${call.callerId == Provider.of<AuthProviders>(context).user!.id ? call.receiverId : call.callerId}\n${call.timestamp}"),
                  trailing: call.duration != null
                      ? Text("${call.duration} sec")
                      : null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
