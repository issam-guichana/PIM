// lib/Views/Patient/Jeux/GamesPage.dart

import 'package:flutter/material.dart';
import 'package:version1/Views/Patient/Jeux/CandyPage.dart';
import 'package:version1/Views/Patient/Jeux/PuzzlePage.dart';
// 👉 Import de ta page QuizPage :
import 'package:version1/Views/Patient/Jeux/QuizPage.dart';

class GamesPage extends StatelessWidget {
  const GamesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jeux pour Alzheimer'),
        backgroundColor: const Color(0xFF723D92),
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: [
          _buildGameCard(
            context,
            title: 'Puzzle',
            icon: Icons.extension,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PuzzlePage()),
            ),
          ),
          _buildGameCard(
            context,
            title: 'Candy',
            icon: Icons.cake,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AdvancedCandyPage()),
            ),
          ),
          // 🎯 Nouveau bouton pour ton Quiz MéMo
          _buildGameCard(
            context,
            title: 'Quiz MéMo',
            icon: Icons.quiz, // ou Icons.memory selon ton goût
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const QuizPage()),
            ),
          ),
          // Tu peux laisser le dernier pour un futur jeu ou le dupliquer :
          _buildGameCard(
            context,
            title: 'Jeu Mémoire 2',
            icon: Icons.grain,
            onTap: () {
              // TODO : ajouter une autre page de jeu ici
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGameCard(
      BuildContext context, {
      required String title,
      required IconData icon,
      required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: Colors.deepPurple.shade100,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 4,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 50, color: Colors.deepPurple),
              const SizedBox(height: 10),
              Text(title, style: const TextStyle(fontSize: 18)),
            ],
          ),
        ),
      ),
    );
  }
}
