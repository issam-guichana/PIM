import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:version1/Views/Avatar/talking_avatar_page.dart';
import 'package:version1/Views/Avatar/utils.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:photo_manager/photo_manager.dart';

class Profile extends StatefulWidget {
  const Profile({super.key, required this.data});

  final ProfileData data;

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  late final WebViewController _controller;
  final api = 'https://api.readyplayer.me/v1/avatars/';
  bool isThreeD = false;
  late String twoDUrl;
  int idx = 0;
  bool webViewInitialized = false;

  @override
  void initState() {
    super.initState();
    twoDUrl = '$api${widget.data.avatarId}.png';
    _initWebView();
  }

  Future<void> _initWebView() async {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (page) {
          debugPrint(widget.data.avatarUrl);
          _controller.runJavaScript(
              'window.loadViewer("${widget.data.avatarUrl}");');
        },
      ))
      ..loadFlutterAsset('assets/viewer.html');
    setState(() => webViewInitialized = true);
  }

  void _downloadCurrentModel() async {
    final url = isThreeD ? widget.data.avatarUrl : twoDUrl;

    if (!isThreeD) {
      final permission = await PhotoManager.requestPermissionExtend();
      if (!permission.isAuth) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Permission denied to access photos")),
        );
        return;
      }

      try {
        final response = await http.get(Uri.parse(url!));
        await PhotoManager.editor.saveImage(
          response.bodyBytes,
          filename: "avatar_${DateTime.now().millisecondsSinceEpoch}.png",
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("2D Avatar saved to Photos")),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${e.toString()}")),
        );
      }
    } else {
      if (await canLaunchUrl(Uri.parse(url!))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          tooltip: 'Back to Avatar Selector',
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              height: 20,
              child: ToggleSwitch(
                initialLabelIndex: idx,
                labels: const ['2D', '3D'],
                cornerRadius: 20.0,
                totalSwitches: 2,
                customWidths: const [40, 40],
                onToggle: (index) {
                  setState(() {
                    idx = index ?? 0;
                    isThreeD = index == 1;
                    if (isThreeD && !webViewInitialized) {
                      _initWebView();
                    }
                  });
                },
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.download_rounded, color: Colors.deepPurple),
              tooltip: 'Download Avatar',
              onPressed: _downloadCurrentModel,
            ),
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (isThreeD && webViewInitialized)
            WebViewWidget(controller: _controller)
          else
            Image.network(twoDUrl, fit: BoxFit.cover),
        ],
      ),
      bottomSheet: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        height: 200,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: ElevatedButton.icon(
                 onPressed: () {
  final urlToSend = isThreeD ? widget.data.avatarUrl! : twoDUrl;
  debugPrint("Navigating to TalkingAvatarPage with avatar: $urlToSend");

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => TalkingAvatarPage(urlToSend),
    ),
  );
},

                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 12),
                  ),
                  icon: const Icon(Icons.record_voice_over_rounded),
                  label: const Text("Talk With Avatar"),
                ),
              ),
              const SizedBox(height: 10),
              Text.rich(
                TextSpan(
                  text: 'AMIRA GHARBI\n',
                  style: GoogleFonts.bungeeInline(fontSize: 26),
                  children: [
                    TextSpan(
                      text: '@amiragharbi',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'amiragharbi@gmail.com',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'amira is a 3D artist and designer based in New York City. '
                'He is a graduate of the Art Institute of New York City and '
                'has been working in the industry for 5 years.',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
