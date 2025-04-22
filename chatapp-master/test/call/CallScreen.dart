import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class CallScreen extends StatefulWidget {
  final String callId;
  final String callerId;
  final String receiverId;
  final String type;
  final String sdp; // SDP offer (if not the caller)
  final bool isCaller;

  const CallScreen({
    super.key,
    required this.callId,
    required this.callerId,
    required this.receiverId,
    required this.type,
    required this.sdp,
    required this.isCaller,
  });

  @override
  _CallScreenState createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  MediaStream? _remoteStream;
  RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  late IO.Socket socket;
  DateTime? callStartTime;

  @override
  void initState() {
    super.initState();
    _initRenderers();
    _connectSocket();
    _setupWebRTC();
    callStartTime = DateTime.now();
  }

  Future<void> _initRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
  }

  void _connectSocket() {
    socket = IO.io('http://192.168.42.253:3000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });
    socket.connect();

    // Listen for SDP answer from the callee (if caller)
    socket.on('answerCall', (data) async {
      if (widget.isCaller && data['callId'] == widget.callId) {
        await _peerConnection!.setRemoteDescription(
          RTCSessionDescription(data['sdp'], 'answer'),
        );
      }
    });

    // Listen for ICE candidates from the other peer
    socket.on('iceCandidate', (data) async {
      if (data['callId'] == widget.callId) {
        final candidate = RTCIceCandidate(
          data['candidate']['candidate'],
          data['candidate']['sdpMid'],
          data['candidate']['sdpMLineIndex'],
        );
        await _peerConnection!.addCandidate(candidate);
      }
    });
  }

  Future<void> _setupWebRTC() async {
    // WebRTC configuration with STUN server
    final configuration = {
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
      ],
    };

    // Create peer connection
    _peerConnection = await createPeerConnection(configuration);

    // Request media (audio/video) permissions
    _localStream = await navigator.mediaDevices.getUserMedia({
      'audio': true,
      'video': widget.type == 'video',
    });

    // Add local stream tracks to the peer connection
    _localStream!.getTracks().forEach((track) {
      _peerConnection!.addTrack(track, _localStream!);
    });

    // Set local stream to renderer
    _localRenderer.srcObject = _localStream;

    // Handle incoming remote stream
    _peerConnection!.onTrack = (event) {
      if (event.streams.isNotEmpty) {
        setState(() {
          _remoteStream = event.streams[0];
          _remoteRenderer.srcObject = _remoteStream;
        });
      }
    };

    // Handle ICE candidates and send them to the other peer
    _peerConnection!.onIceCandidate = (candidate) {
      socket.emit('iceCandidate', {
        'callId': widget.callId,
        'callerId': widget.callerId,
        'receiverId': widget.receiverId,
        'candidate': {
          'candidate': candidate.candidate,
          'sdpMid': candidate.sdpMid,
          'sdpMLineIndex': candidate.sdpMLineIndex,
        },
      });
    };

    // SDP exchange
    if (widget.isCaller) {
      // Caller: Create and send SDP offer
      final offer = await _peerConnection!.createOffer();
      await _peerConnection!.setLocalDescription(offer);
      socket.emit('startCall', {
        'callId': widget.callId,
        'callerId': widget.callerId,
        'receiverId': widget.receiverId,
        'type': widget.type,
        'sdp': offer.sdp, // Send actual SDP offer
      });
    } else {
      // Callee: Set remote offer, create answer, and send it
      await _peerConnection!.setRemoteDescription(
        RTCSessionDescription(widget.sdp, 'offer'),
      );
      final answer = await _peerConnection!.createAnswer();
      await _peerConnection!.setLocalDescription(answer);
      socket.emit('answerCall', {
        'callId': widget.callId,
        'callerId': widget.callerId,
        'receiverId': widget.receiverId,
        'accepted': true,
        'sdp': answer.sdp, // Send actual SDP answer
      });
    }
  }

  void _endCall() {
    final duration = DateTime.now().difference(callStartTime!).inSeconds;
    socket.emit('endCall', {
      'callId': widget.callId,
      'duration': duration,
    });

    _peerConnection?.close();
    _localStream?.dispose();
    _remoteStream?.dispose();
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    socket.disconnect();
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _endCall();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.type} Call"),
        backgroundColor: const Color(0xFF723D92),
      ),
      body: Stack(
        children: [
          if (widget.type == 'video')
            RTCVideoView(_remoteRenderer, mirror: false),
          if (widget.type == 'video')
            Positioned(
              right: 20,
              bottom: 20,
              child: SizedBox(
                width: 100,
                height: 150,
                child: RTCVideoView(_localRenderer, mirror: true),
              ),
            ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                onPressed: _endCall,
                icon: const Icon(Icons.call_end),
                label: const Text("End Call"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
