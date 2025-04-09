import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PuzzlePage extends StatefulWidget {
  const PuzzlePage({super.key});

  @override
  State<PuzzlePage> createState() => _PuzzlePageState();
}

class _PuzzlePageState extends State<PuzzlePage> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent(
        "Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) "
        "AppleWebKit/605.1.15 (KHTML, like Gecko) "
        "Version/13.0.3 Mobile/15E148 Safari/604.1",
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (url) {
            _injectPersistentZoom();
          },
        ),
      )
      ..loadRequest(Uri.parse('https://games.memory-motivation.org/?lang=fr'));
  }

  void _injectPersistentZoom() {
    _controller.runJavaScript('''
      (function() {
        function applyZoom() {
          var viewport = document.querySelector('meta[name=viewport]');
          if (viewport) {
            viewport.setAttribute('content', 'width=device-width, initial-scale=0.5, maximum-scale=1.0, user-scalable=no');
          }
          document.body.style.zoom = '0.75';
        }

        applyZoom(); // initial

        setInterval(() => {
          applyZoom();
        }, 1000); // vérifie toutes les 1 seconde
      })();
    ''');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jeu de Puzzle'),
        backgroundColor: const Color(0xFF723D92),
      ),
      body: SafeArea(
        child: SizedBox.expand(
          child: WebViewWidget(controller: _controller),
        ),
      ),
    );
  }
}
