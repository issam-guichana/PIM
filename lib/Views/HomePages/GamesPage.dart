import 'package:flutter/material.dart';
import 'package:tesst1/Views/HomePages/PuzzlePage.dart';
import 'package:tesst1/Views/HomePages/candypage.dart'; // Votre import existant

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
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PuzzlePage()),
              );
            },
          ),
          _buildGameCard(
            context,
            title: 'Candy',
            icon: Icons.cake,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AdvancedCandyPage()),
              );
            },
          ),
          _buildGameCard(
            context,
            title: 'Jeu Mémoire 1',
            icon: Icons.memory,
            onTap: () {
              // À implémenter
            },
          ),
          _buildGameCard(
            context,
            title: 'Jeu Mémoire 2',
            icon: Icons.grain,
            onTap: () {
              // À implémenter
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGameCard(BuildContext context,
      {required String title, required IconData icon, required VoidCallback onTap}) {
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