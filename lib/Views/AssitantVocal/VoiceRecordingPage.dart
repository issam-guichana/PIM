import 'package:flutter/material.dart';
import 'package:flutter_sound_record/flutter_sound_record.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:io';
import 'package:intl/intl.dart';

class VoiceRecordingPage extends StatefulWidget {
  const VoiceRecordingPage({super.key});

  @override
  _VoiceRecordingPageState createState() => _VoiceRecordingPageState();
}

class _VoiceRecordingPageState extends State<VoiceRecordingPage> {
  bool _isRecording = false;
  bool _isPlaying = false;
  int _recordDuration = 0; // Duration in seconds
  int _playPosition = 0; // Playback position in milliseconds
  int _playDuration = 0; // Playback duration in milliseconds
  final List<String> _textsToRead = [
    "The quick brown fox jumps over the lazy dog.",
    "A journey of a thousand miles begins with a single step.",
    "To be or not to be, that is the question."
  ];
  int _currentTextIndex = 0;
  late FlutterSoundRecord _recorder;
  late FlutterSoundPlayer _player;
  String? _filePath;
  String? _currentPlayingPath;
  Timer? _timer;
  Timer? _playTimer;
  Amplitude? _amplitude;
  Timer? _ampTimer;
  List<RecordingItem> _recordings = []; // List to store recording information

  @override
  void initState() {
    super.initState();
    _recorder = FlutterSoundRecord();
    _player = FlutterSoundPlayer();
    _initPlayer();
    _loadExistingRecordings();
  }

  // Load any existing recordings
  Future<void> _loadExistingRecordings() async {
    final directory = await getApplicationDocumentsDirectory();
    final dir = Directory(directory.path);
    List<FileSystemEntity> files = dir.listSync();

    List<RecordingItem> recordings = [];
    for (var file in files) {
      if (file.path.endsWith('.m4a') && file.path.contains('voice_sample_')) {
        final fileName = file.path.split('/').last;
        final timestamp =
            int.tryParse(fileName.split('_').last.split('.').first);
        if (timestamp != null) {
          final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
          recordings.add(RecordingItem(
            path: file.path,
            name: 'Recording ${recordings.length + 1}',
            date: date,
          ));
        }
      }
    }

    // Sort recordings by date (newest first)
    recordings.sort((a, b) => b.date.compareTo(a.date));

    setState(() {
      _recordings = recordings;
    });
  }

  // Initialize the audio player
  Future<void> _initPlayer() async {
    await _player.openPlayer();
    _player.setSubscriptionDuration(const Duration(milliseconds: 200));
  }

  // Start recording
  Future<void> _startRecording() async {
    if (await _recorder.hasPermission()) {
      final directory = await getApplicationDocumentsDirectory();
      _filePath =
          '${directory.path}/voice_sample_${DateTime.now().millisecondsSinceEpoch}.m4a';

      await _recorder.start(path: _filePath);
      bool isRecording = await _recorder.isRecording();
      setState(() {
        _isRecording = isRecording;
        _recordDuration = 0;
      });
      _startTimer();
      print("Recording started...");
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please grant microphone permission")),
      );
      print("Microphone permission denied.");
    }
  }

  // Stop recording
  Future<void> _stopRecording() async {
    _timer?.cancel();
    _ampTimer?.cancel();
    final String? path = await _recorder.stop();

    if (path != null) {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final newRecording = RecordingItem(
        path: path,
        name: 'Recording ${_recordings.length + 1}',
        date: DateTime.now(),
      );

      setState(() {
        _recordings.insert(
            0, newRecording); // Add at the beginning (newest first)
      });
    }

    setState(() {
      _isRecording = false;
      if (_currentTextIndex < _textsToRead.length - 1) {
        _currentTextIndex++;
      } else {
        _currentTextIndex = 0; // Loop back to start
      }
    });
    print("Recording saved at: $path");
  }

  // Play recorded audio
  Future<void> _playRecording(String filePath) async {
    if (_isPlaying) {
      await _stopPlayback();
      if (_currentPlayingPath == filePath) {
        return; // If tapping the same recording that's playing, just stop
      }
    }

    await _player.startPlayer(
      fromURI: filePath,
      whenFinished: () {
        setState(() {
          _isPlaying = false;
          _currentPlayingPath = null;
        });
        _playTimer?.cancel();
      },
    );

    _player.onProgress!.listen((event) {
      setState(() {
        _playPosition = event.position.inMilliseconds;
        _playDuration = event.duration.inMilliseconds;
      });
    });

    setState(() {
      _isPlaying = true;
      _currentPlayingPath = filePath;
    });

    _startPlayTimer();
  }

  // Stop playback
  Future<void> _stopPlayback() async {
    await _player.stopPlayer();
    _playTimer?.cancel();
    setState(() {
      _isPlaying = false;
      _currentPlayingPath = null;
    });
  }

  // Start the timer and amplitude updates
  void _startTimer() {
    _timer?.cancel();
    _ampTimer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      setState(() => _recordDuration++);
    });

    _ampTimer =
        Timer.periodic(const Duration(milliseconds: 200), (Timer t) async {
      _amplitude = await _recorder.getAmplitude();
      setState(() {});
    });
  }

  // Start playback timer
  void _startPlayTimer() {
    _playTimer?.cancel();
    _playTimer = Timer.periodic(const Duration(milliseconds: 200), (Timer t) {
      if (!_isPlaying) {
        _playTimer?.cancel();
      }
    });
  }

  // Format timer display
  String _formatTimer(int seconds) {
    final minutes = _formatNumber(seconds ~/ 60);
    final secs = _formatNumber(seconds % 60);
    return '$minutes:$secs';
  }

  String _formatNumber(int number) {
    return number < 10 ? '0$number' : number.toString();
  }

  // Format milliseconds for playback display
  String _formatPlaybackTime(int milliseconds) {
    int seconds = (milliseconds / 1000).floor();
    return _formatTimer(seconds);
  }

  // Format date for display
  String _formatDate(DateTime date) {
    return DateFormat('MMM d, yyyy • h:mm a').format(date);
  }

  // Delete a recording
  void _deleteRecording(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Recording'),
          content:
              const Text('Are you sure you want to delete this recording?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () {
                // If currently playing this recording, stop playback
                if (_currentPlayingPath == _recordings[index].path) {
                  _stopPlayback();
                }

                // Delete the file
                File(_recordings[index].path).deleteSync();

                // Remove from list
                setState(() {
                  _recordings.removeAt(index);
                });

                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ampTimer?.cancel();
    _playTimer?.cancel();
    _recorder.dispose();
    _player.closePlayer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const SizedBox(height: 50),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 10,
              shadowColor: const Color(0xFF723D92),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Read Aloud',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF723D92),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _textsToRead[_currentTextIndex],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _isRecording
                          ? 'Recording... (${_formatTimer(_recordDuration)})'
                          : _isPlaying
                              ? 'Playing... (${_formatPlaybackTime(_playPosition)} / ${_formatPlaybackTime(_playDuration)})'
                              : 'Press to Record',
                      style: TextStyle(
                        fontSize: 14,
                        color: _isRecording
                            ? Colors.red
                            : _isPlaying
                                ? Colors.blue
                                : Colors.grey,
                      ),
                    ),
                    if (_amplitude != null && _isRecording) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Amplitude: ${_amplitude!.current.toStringAsFixed(1)} dB',
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                    if (_isPlaying) ...[
                      const SizedBox(height: 12),
                      LinearProgressIndicator(
                        value: _playDuration > 0
                            ? _playPosition / _playDuration
                            : 0.0,
                        backgroundColor: Colors.grey[300],
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Color(0xFF723D92)),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 5,
                shadowColor: const Color(0xFF723D92),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Your Recordings',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF723D92),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _recordings.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.mic_none,
                                    size: 48,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No recordings yet',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Press the microphone button to start recording',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Expanded(
                              child: ListView.separated(
                                itemCount: _recordings.length,
                                separatorBuilder: (context, index) => Divider(
                                  color: Colors.grey[300],
                                  height: 1,
                                ),
                                itemBuilder: (context, index) {
                                  final recording = _recordings[index];
                                  final isCurrentlyPlaying = _isPlaying &&
                                      _currentPlayingPath == recording.path;

                                  return ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading: GestureDetector(
                                      onTap: () {
                                        _playRecording(recording.path);
                                      },
                                      child: Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF723D92)
                                              .withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(25),
                                        ),
                                        child: Icon(
                                          isCurrentlyPlaying
                                              ? Icons.pause
                                              : Icons.play_arrow,
                                          color: const Color(0xFF723D92),
                                          size: 30,
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      recording.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _formatDate(recording.date),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        if (isCurrentlyPlaying) ...[
                                          const SizedBox(height: 8),
                                          LinearProgressIndicator(
                                            value: _playDuration > 0
                                                ? _playPosition / _playDuration
                                                : 0.0,
                                            backgroundColor: Colors.grey[300],
                                            valueColor:
                                                const AlwaysStoppedAnimation<
                                                    Color>(Color(0xFF723D92)),
                                            minHeight: 3,
                                          ),
                                        ],
                                      ],
                                    ),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.delete_outline,
                                          color: Colors.red),
                                      onPressed: () => _deleteRecording(index),
                                    ),
                                  );
                                },
                              ),
                            ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: FloatingActionButton(
              onPressed: _isRecording ? _stopRecording : _startRecording,
              backgroundColor: const Color(0xFF723D92),
              child: Icon(
                _isRecording ? Icons.stop : Icons.mic,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Class to store recording information
class RecordingItem {
  final String path;
  final String name;
  final DateTime date;

  RecordingItem({
    required this.path,
    required this.name,
    required this.date,
  });
}
