import 'package:flutter/material.dart';

class AdviceScreen extends StatelessWidget {
  final String advice;

  const AdviceScreen({super.key, required this.advice, required Map<String, dynamic> fitData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Conseils de Santé"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Conseils de l'IA (Gemini)",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              advice,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
