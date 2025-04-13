import 'package:flutter/material.dart';
import 'package:flutter_sound_record/flutter_sound_record.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:io';

class VoiceRecordingPage extends StatefulWidget {
  @override
  _VoiceRecordingPageState createState() => _VoiceRecordingPageState();
}

class _VoiceRecordingPageState extends State<VoiceRecordingPage> {
  bool _isRecording = false;
  bool _isPlaying = false;
  bool _hasRecording = false;
  int _recordDuration = 0; // Duration in seconds
  int _playPosition = 0; // Playback position in milliseconds
  int _playDuration = 0; // Playback duration in milliseconds

  // Single text to read
  final String _textToRead = "الصباح كي نفيق، أول حاجة نعملها نحل الشباك و نخلي الشمس تدخل. نحسها تعطيني طاقة إيجابية لنهاري. نحضّر فطور خفيف، و نشرب قهوتي على رواقي. نحب نبدأ نهاري بالهدوء، بعيد على الستراس. بعد نلبس و نخرج، كل يوم فيه مغامرة جديدة، و ديما نقول: المهم تبقى ديما تضحك و تمشي لقدّام.";

  late FlutterSoundRecord _recorder;
  late FlutterSoundPlayer _player;
  String? _recordingPath;
  Timer? _timer;
  Timer? _playTimer;
  Amplitude? _amplitude;
  Timer? _ampTimer;
  DateTime? _recordingDate;

  @override
  void initState() {
    super.initState();
    _recorder = FlutterSoundRecord();
    _player = FlutterSoundPlayer();
    _initPlayer();
    _checkExistingRecording();
  }

  // Check if a recording already exists
  Future<void> _checkExistingRecording() async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/voice_sample.m4a';
    final file = File(filePath);

    if (await file.exists()) {
      setState(() {
        _hasRecording = true;
        _recordingPath = filePath;
        // Get the file's last modified date as recording date
        file.lastModified().then((value) {
          setState(() {
            _recordingDate = value;
          });
        });
      });
    }
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
      _recordingPath = '${directory.path}/voice_sample.m4a';

      // Delete previous recording if exists
      final file = File(_recordingPath!);
      if (await file.exists()) {
        await file.delete();
      }

      await _recorder.start(path: _recordingPath);
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

    setState(() {
      _isRecording = false;
      _hasRecording = path != null;
      _recordingDate = DateTime.now();
    });
    print("Recording saved at: $path");
  }

  // Play recorded audio
  Future<void> _playRecording() async {
    if (_isPlaying) {
      await _stopPlayback();
      return;
    }

    if (_recordingPath != null) {
      await _player.startPlayer(
        fromURI: _recordingPath!,
        whenFinished: () {
          setState(() {
            _isPlaying = false;
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
      });

      _startPlayTimer();
    }
  }

  // Stop playback
  Future<void> _stopPlayback() async {
    await _player.stopPlayer();
    _playTimer?.cancel();
    setState(() {
      _isPlaying = false;
    });
  }

  // Delete the recording
  Future<void> _deleteRecording() async {
    if (_isPlaying) {
      await _stopPlayback();
    }

    if (_recordingPath != null) {
      final file = File(_recordingPath!);
      if (await file.exists()) {
        await file.delete();
      }

      setState(() {
        _hasRecording = false;
        _recordingPath = null;
        _recordingDate = null;
      });
    }
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 24),
              Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 10,
                shadowColor: const Color(0xFF723D92),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Read Aloud',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF723D92),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _textToRead,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Expanded(
                child: Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 5,
                  shadowColor: const Color(0xFF723D92),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_isRecording) ...[
                          const Icon(
                            Icons.mic,
                            color: Colors.red,
                            size: 80,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Recording... ${_formatTimer(_recordDuration)}',
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.red
                            ),
                          ),
                          if (_amplitude != null) ...[
                            const SizedBox(height: 12),
                            Container(
                              height: 60,
                              child: Center(
                                child: _VoiceWaveWidget(
                                  amplitude: _amplitude!.current,
                                ),
                              ),
                            ),
                          ],
                        ] else if (_hasRecording) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: _playRecording,
                                child: Container(
                                  width: 70,
                                  height: 70,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF723D92).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(35),
                                  ),
                                  child: Icon(
                                    _isPlaying ? Icons.pause : Icons.play_arrow,
                                    color: const Color(0xFF723D92),
                                    size: 40,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 30),
                              GestureDetector(
                                onTap: _deleteRecording,
                                child: Container(
                                  width: 70,
                                  height: 70,
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(35),
                                  ),
                                  child: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.red,
                                    size: 40,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          if (_isPlaying) ...[
                            Text(
                              'Playing... ${_formatPlaybackTime(_playPosition)} / ${_formatPlaybackTime(_playDuration)}',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color(0xFF723D92),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20.0),
                              child: LinearProgressIndicator(
                                value: _playDuration > 0
                                    ? _playPosition / _playDuration
                                    : 0.0,
                                backgroundColor: Colors.grey[300],
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                    Color(0xFF723D92)),
                                minHeight: 4,
                              ),
                            ),
                          ] else ...[
                            const Text(
                              'Recording complete',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.green,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Press play to listen or record again',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ] else ...[
                          Icon(
                            Icons.mic_none,
                            size: 80,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'No recording yet',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Press the button below to start recording',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (!_hasRecording || _isRecording)
                FloatingActionButton.extended(
                  onPressed: _isRecording ? _stopRecording : _startRecording,
                  backgroundColor: _isRecording ? Colors.red : const Color(0xFF723D92),
                  icon: Icon(
                    _isRecording ? Icons.stop : Icons.mic,
                    color: Colors.white,
                  ),
                  label: Text(
                    _isRecording ? 'Stop' : (_hasRecording ? 'Re-record' : 'Start Recording'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom widget to show voice amplitude visualization
class _VoiceWaveWidget extends StatelessWidget {
  final double amplitude;

  const _VoiceWaveWidget({required this.amplitude});

  @override
  Widget build(BuildContext context) {
    // Normalize amplitude for visualization (typically -160 to 0 dB)
    double normalizedAmplitude = (amplitude + 160) / 160;
    if (normalizedAmplitude < 0) normalizedAmplitude = 0;
    if (normalizedAmplitude > 1) normalizedAmplitude = 1;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(9, (index) {
        // Create different heights for each bar to simulate a waveform
        double height = 10 + normalizedAmplitude * 40;
        if (index % 2 == 0) height *= 0.6;
        if (index % 3 == 0) height *= 1.3;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3.0),
          child: Container(
            width: 5,
            height: height,
            decoration: BoxDecoration(
              color: const Color(0xFF723D92),
              borderRadius: BorderRadius.circular(5),
            ),
          ),
        );
      }),
    );
  }
}