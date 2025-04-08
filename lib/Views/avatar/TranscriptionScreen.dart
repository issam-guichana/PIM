import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tesst1/Controllers/avatarProvider.dart'; // Assure-toi que ce chemin est correct

class SpeechView extends StatelessWidget {
  const SpeechView({super.key});

  @override
  Widget build(BuildContext context) {
    final avatarProvider = Provider.of<AvatarProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transcription Vocale'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Zone de transcription vocale
            Text(
              avatarProvider.transcription.isNotEmpty
                  ? avatarProvider.transcription
                  : "🎤 Parlez pour voir la transcription...",
              style: const TextStyle(fontSize: 24),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            // Bouton de redémarrage du micro
            ElevatedButton.icon(
              onPressed: () async {
                await avatarProvider.restartMicrophone();
              },
              icon: const Icon(Icons.mic),
              label: const Text("Redémarrer le micro"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
