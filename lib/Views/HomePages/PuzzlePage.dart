import 'package:flutter/material.dart';
import 'dart:math';

class PuzzlePage extends StatefulWidget {
  const PuzzlePage({super.key});

  @override
  State<PuzzlePage> createState() => _PuzzlePageState();
}

class _PuzzlePageState extends State<PuzzlePage> {
  late List<int> tiles; 
  final int gridSize = 3; 
  int emptyIndex = 8;
  bool _isInitialized = false; 

  @override
  void initState() {
    super.initState();
    _resetTiles(); 
  }

  void _resetTiles() {
    tiles = List.generate(gridSize * gridSize - 1, (index) => index + 1)
      ..add(0); 
    emptyIndex = 8; 
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _shuffleTiles();
      _isInitialized = true;
    }
  }

  void _shuffleTiles() {
    final random = Random();
    // Réinitialiser les tuiles avant de mélanger
    _resetTiles();
    // Mélanger les tuiles de manière aléatoire
    for (int i = 0; i < 100; i++) {
      int randomIndex = random.nextInt(tiles.length);
      _moveTile(randomIndex, updateState: false); // Ne pas appeler setState ici
    }
    // Mettre à jour l'état une seule fois après le mélange
    setState(() {});
  }

  bool _canMove(int index) {
    int row = index ~/ gridSize;
    int col = index % gridSize;
    int emptyRow = emptyIndex ~/ gridSize;
    int emptyCol = emptyIndex % gridSize;

    return (row == emptyRow && (col - emptyCol).abs() == 1) ||
        (col == emptyCol && (row - emptyRow).abs() == 1);
  }

  void _moveTile(int index, {bool updateState = true}) {
    if (_canMove(index)) {
      tiles[emptyIndex] = tiles[index];
      tiles[index] = 0;
      emptyIndex = index;
      if (updateState) {
        setState(() {});
        if (_isSolved()) {
          _showWinDialog();
        }
      }
    }
  }

  bool _isSolved() {
    for (int i = 0; i < tiles.length - 1; i++) {
      if (tiles[i] != i + 1) return false;
    }
    return tiles.last == 0;
  }

  void _showWinDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Félicitations !'),
        content: const Text('Vous avez résolu le puzzle !'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Mélanger les tuiles pour un nouveau jeu
              Future.delayed(Duration.zero, () {
                _shuffleTiles();
              });
            },
            child: const Text('Rejouer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jeu de Puzzle'),
        backgroundColor: const Color(0xFF723D92),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Résolvez le Puzzle !',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 300,
              height: 300,
              child: GridView.count(
                crossAxisCount: gridSize,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
                children: List.generate(gridSize * gridSize, (index) {
                  return GestureDetector(
                    onTap: () => _moveTile(index),
                    child: Container(
                      decoration: BoxDecoration(
                        color: tiles[index] == 0
                            ? Colors.grey.shade300
                            : Colors.deepPurple.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.deepPurple),
                      ),
                      child: Center(
                        child: tiles[index] == 0
                            ? null
                            : Text(
                                '${tiles[index]}',
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepPurple,
                                ),
                              ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Future.delayed(Duration.zero, () {
                  _shuffleTiles();
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
              ),
              child: const Text('Mélanger'),
            ),
          ],
        ),
      ),
    );
  }
}