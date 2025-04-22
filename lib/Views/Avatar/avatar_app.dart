import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'profile.dart';
import 'utils.dart';

class AvatarApp extends StatelessWidget {
  final SharedPreferences prefs;
  const AvatarApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: AvatarHomePage(prefs: prefs),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AvatarHomePage extends StatefulWidget {
  final SharedPreferences prefs;
  const AvatarHomePage({super.key, required this.prefs});

  @override
  State<AvatarHomePage> createState() => _AvatarHomePageState();
}

class _AvatarHomePageState extends State<AvatarHomePage> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  Future<void> _initWebView() async {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'AvatarCreated',
        onMessageReceived: (JavaScriptMessage message) async {
          await widget.prefs.setString('avatar', message.message);
          final user = userFromPrefs(widget.prefs);
          if (!mounted) return;
          if (user != null) {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Profile(data: user)),
            );
            await loadHtmlFromAssets(_controller, 'assets/iframe.html');
          }
        },
      )
      ..loadFlutterAsset('assets/iframe.html');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: _controller == null
          ? const Center(child: CircularProgressIndicator())
          : WebViewWidget(controller: _controller),
    );
  }
}
