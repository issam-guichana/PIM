import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:version1/Providers/AvatarProvider.dart';
import 'package:version1/Views/Avatar/utils.dart' show userFromPrefs;
import 'package:webview_flutter/webview_flutter.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class TalkingAvatarPage extends StatefulWidget {
  final String? avatarUrl;
  const TalkingAvatarPage(this.avatarUrl, {super.key});

  @override
  State<TalkingAvatarPage> createState() => _TalkingAvatarPageState();
}

class _TalkingAvatarPageState extends State<TalkingAvatarPage> with TickerProviderStateMixin {
  late final WebViewController _controller;
  final TextEditingController _textController = TextEditingController(text: "Hello Aziz, welcome back!");
  String avatarUrl = "";
  bool isReady = false;
  bool isGenerating = false;
  bool isShowingVideo = false;
  late AnimationController _fadeController;
  double opacity = 1.0;

  // Speech recognition variables
  SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = '';

  @override
  void initState() {
    super.initState();
    debugPrint("[LOG] initState called");
    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _fadeController.addListener(() {
      setState(() {
        opacity = 1.0 - _fadeController.value;
      });
    });
    _initWebView();
    loadAvatarUrl();
    _initSpeech();
  }

  // Initialize WebView
  Future<void> _initWebView() async {
    debugPrint("[LOG] Initializing WebView...");
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel('VideoEnded', onMessageReceived: (JavaScriptMessage msg) async {
        debugPrint("[LOG] VideoEnded message received: ${msg.message}");
        if (msg.message == 'done') {
          await _fadeController.forward(from: 0);
          setState(() => isShowingVideo = false);
          await Future.delayed(const Duration(milliseconds: 300));
          if (mounted) {
            await _loadAvatarContent();
          }
          _fadeController.reset();
          setState(() => opacity = 1.0);
        }
      });
    debugPrint("[LOG] WebView initialized successfully");
  }

  // Dispose resources
  @override
  void dispose() {
    debugPrint("[LOG] Disposing resources...");
    _fadeController.dispose();
    super.dispose();
  }

  // Load Avatar URL
  Future<void> loadAvatarUrl() async {
    debugPrint("[LOG] Loading avatar URL...");
    if (widget.avatarUrl != null && widget.avatarUrl!.isNotEmpty) {
      debugPrint("[LOG] Using avatar URL from widget: ${widget.avatarUrl}");
      avatarUrl = widget.avatarUrl!;
    } else {
      final prefs = await SharedPreferences.getInstance();
      final user = userFromPrefs(prefs);
      if (user != null && user.avatarUrl != null) {
        debugPrint("[LOG] Using avatar URL from preferences: ${user.avatarUrl}");
        avatarUrl = user.avatarUrl!;
      }
    }
    if (avatarUrl.isNotEmpty) {
      debugPrint("[LOG] Avatar URL loaded successfully: $avatarUrl");
      setState(() => isReady = true);
      await _loadAvatarContent();
    } else {
      debugPrint("[LOG] No avatar URL found");
    }
  }

  // Load Avatar content (GLB or PNG)
  Future<void> _loadAvatarContent() async {
    debugPrint("[LOG] Loading avatar content...");
    if (avatarUrl.endsWith(".glb")) {
      debugPrint("[LOG] Loading GLB model...");
      final html = await rootBundle.loadString('assets/glb_viewer.html');
      final replacedHtml = html.replaceFirst('__MODEL_URL__', avatarUrl);
      await _controller.loadHtmlString(replacedHtml);
    } else {
      debugPrint("[LOG] Loading PNG avatar...");
      await _controller.loadHtmlString(_pngAvatarHtml);
    }
    debugPrint("[LOG] Avatar content loaded successfully");
  }

  String get _pngAvatarHtml => '''
<!DOCTYPE html>
<html>
  <head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <style>
      body {
        margin: 0;
        background: white;
        display: flex;
        justify-content: center;
        align-items: center;
        height: 100vh;
      }
      img {
        max-width: 80%;
        max-height: 90%;
        object-fit: contain;
      }
    </style>
  </head>
  <body>
    <img src="$avatarUrl" alt="Avatar">
  </body>
</html>
''';

  // Speech generation using ChatGPT and D-ID
  Future<void> _speak() async {
  final prompt = _textController.text.trim();
  if (prompt.isEmpty || avatarUrl.endsWith(".glb")) {
    debugPrint("[LOG] Prompt is empty or avatar is GLB. Skipping speech generation.");
    return;
  }

  debugPrint("[LOG] Starting speech generation...");
  setState(() => isGenerating = true);

  try {
    debugPrint("[LOG] Fetching response from ChatGPT...");
    final gptService = Provider.of<ChatGPTService>(context, listen: false);
    final gptResponse = await gptService.getResponse(prompt);

    // Ensure gptResponse is a string
    if (gptResponse is List) {
      debugPrint("[LOG] ChatGPT response is a list, extracting first element.");
      _textController.text = gptResponse.isNotEmpty ? gptResponse[0] : "";
    } else {
      _textController.text = gptResponse;
    }

    debugPrint("[LOG] ChatGPT response: ${_textController.text}");

    // Calling D-ID API with Arabic voice
    debugPrint("[LOG] Sending request to D-ID API...");
    final response = await http.post(
      Uri.parse('https://api.d-id.com/talks'),
      headers: {
        'Authorization': 'Basic YW1pcmEuZ2hhcmJpMjUwNUBnbWFpbC5jb20:qCvDVqwVk_T9S2AvmBKWi',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "script": {
          "type": "text",
          "input": _textController.text,
          "provider": {"type": "microsoft", "voice_id": "ar-EG-HodaNeural"}
        },
        "source_url": avatarUrl,
      }),
    );

    debugPrint("[LOG] D-ID API response status code: ${response.statusCode}");
    debugPrint("[LOG] D-ID API response body: ${response.body}");

    if (response.statusCode == 201) {
      final id = jsonDecode(response.body)['id'];
      final pollUrl = 'https://api.d-id.com/talks/$id';

      debugPrint("[LOG] Polling D-ID API for video generation...");
      for (int i = 0; i < 20; i++) {
        await Future.delayed(const Duration(seconds: 2));
        final pollRes = await http.get(Uri.parse(pollUrl), headers: {
          'Authorization': 'Basic YW1pcmEuZ2hhcmJpMjUwNUBnbWFpbC5jb20:qCvDVqwVk_T9S2AvmBKWi'
        });

        debugPrint("[LOG] Polling response status code: ${pollRes.statusCode}");
        debugPrint("[LOG] Polling response body: ${pollRes.body}");

        final body = jsonDecode(pollRes.body);
        final status = body['status'];

        if (status == 'done') {
          final videoUrl = body['result_url'];
          debugPrint("[LOG] Video generated successfully. Video URL: $videoUrl");

          final videoHtml = '''
            <!DOCTYPE html>
            <html>
            <head>
              <meta name="viewport" content="width=device-width, initial-scale=1.0">
              <style>
                body {
                  margin: 0;
                  background: black;
                  display: flex;
                  justify-content: center;
                  align-items: center;
                  height: 100vh;
                }
                video {
                  width: 100%;
                  height: auto;
                }
              </style>
            </head>
            <body>
              <video autoplay controls onended="VideoEnded.postMessage('done')">
                <source src="$videoUrl" type="video/mp4" />
              </video>
            </body>
            </html>
          ''';

          setState(() => isShowingVideo = true);
          await _controller.loadHtmlString(videoHtml);
          break;
        }
      }
    } else {
      debugPrint("[LOG] Failed to generate video. Status code: ${response.statusCode}");
    }
  } catch (e) {
    debugPrint("[LOG] Error during speech generation: $e");
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to generate video.")));
  } finally {
    debugPrint("[LOG] Speech generation completed.");
    setState(() => isGenerating = false);
  }
}


  // Initialize Speech-to-Text
  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  // Start listening for speech input
  void _startListening() async {
    await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {});
  }

  // Stop listening for speech input
  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  // Handle speech recognition result
   void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _lastWords = result.recognizedWords;
    });
  }

  @override
  Widget build(BuildContext context)
   {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Talking Avatar"),
        backgroundColor: Colors.deepPurple,
      ),
      body: isReady
          ? Stack(
              children: [
                AnimatedOpacity(
                  opacity: opacity,
                  duration: const Duration(milliseconds: 500),
                  child: WebViewWidget(controller: _controller),
                ),
                Positioned(
                  bottom: 35,
                  left: 16,
                  right: 16,
                  child: Material(
                    elevation: 10,
                    borderRadius: BorderRadius.circular(28),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 1.2),
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _textController,
                              style: const TextStyle(fontSize: 16),
                              decoration: const InputDecoration(
                                hintText: "Say something...",
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: avatarUrl.endsWith('.png') ? _speak : null,
                            icon: const Icon(Icons.send),
                            label: const Text("Speak"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                if (isGenerating)
                  Container(
                    color: Colors.black.withOpacity(0.5),
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.deepPurple),
                    ),
                  )
              ],
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
