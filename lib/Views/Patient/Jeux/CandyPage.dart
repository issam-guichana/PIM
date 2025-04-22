import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class AdvancedCandyPage extends StatefulWidget {
  const AdvancedCandyPage({Key? key}) : super(key: key);

  @override
  _AdvancedCandyPageState createState() => _AdvancedCandyPageState();
}

class _AdvancedCandyPageState extends State<AdvancedCandyPage> {
  static const int gridSize = 8;
  static const int candyTypes = 6;
  late List<List<int>> board;
  int score = 0;
  int timerSeconds = 60;
  Timer? gameTimer;
  bool isGameOver = false;
  Pair? selectedCandy;

  @override
  void initState() {
    super.initState();
    _initializeBoard();
    _startTimer();
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    super.dispose();
  }

  void _initializeBoard() {
    Random random = Random();
    board = List.generate(gridSize, (_) => 
      List.generate(gridSize, (_) => random.nextInt(candyTypes)
    ));
    // On efface les matchs initiaux pour démarrer sur un plateau "stable"
    _clearMatches();
  }

  void _startTimer() {
    timerSeconds = 60;
    gameTimer?.cancel();
    gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timerSeconds > 0) {
        setState(() {
          timerSeconds--;
        });
      } else {
        timer.cancel();
        setState(() {
          isGameOver = true;
        });
      }
    });
  }

  // Renvoie une couleur en fonction du type de candy (0 à 5)
  Color getCandyColor(int type) {
    switch (type) {
      case 0:
        return Colors.red;
      case 1:
        return Colors.blue;
      case 2:
        return Colors.green;
      case 3:
        return Colors.yellow;
      case 4:
        return Colors.orange;
      case 5:
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  // Vérifie et supprime les matchs (3 pièces alignées ou plus) sur toute la grille,
  // puis fait "tomber" les pièces et en génère de nouvelles.
  void _clearMatches() {
    bool hasMatch = false;
    List<List<bool>> toClear = List.generate(
      gridSize, (_) => List.generate(gridSize, (_) => false)
    );

    // Vérification des matchs horizontaux
    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize - 2; j++) {
        int candyType = board[i][j];
        if (candyType == board[i][j + 1] && candyType == board[i][j + 2]) {
          toClear[i][j] = true;
          toClear[i][j + 1] = true;
          toClear[i][j + 2] = true;
          hasMatch = true;
        }
      }
    }

    // Vérification des matchs verticaux
    for (int j = 0; j < gridSize; j++) {
      for (int i = 0; i < gridSize - 2; i++) {
        int candyType = board[i][j];
        if (candyType == board[i + 1][j] && candyType == board[i + 2][j]) {
          toClear[i][j] = true;
          toClear[i + 1][j] = true;
          toClear[i + 2][j] = true;
          hasMatch = true;
        }
      }
    }

    if (hasMatch) {
      // Suppression des matchs et ajout au score
      for (int i = 0; i < gridSize; i++) {
        for (int j = 0; j < gridSize; j++) {
          if (toClear[i][j]) {
            board[i][j] = -1; // -1 indique une case vide
            score += 10;
          }
        }
      }
      _collapseBoard();
      // Relancer la vérification pour d'éventuels nouveaux matchs
      Future.delayed(const Duration(milliseconds: 300), () {
        setState(() {
          _clearMatches();
        });
      });
    }
  }

  // Fait "tomber" les candies en dessous des cases vides et génère de nouveaux candies en haut.
  void _collapseBoard() {
    Random random = Random();
    for (int j = 0; j < gridSize; j++) {
      int emptyCount = 0;
      for (int i = gridSize - 1; i >= 0; i--) {
        if (board[i][j] == -1) {
          emptyCount++;
        } else if (emptyCount > 0) {
          board[i + emptyCount][j] = board[i][j];
          board[i][j] = -1;
        }
      }
      for (int i = 0; i < emptyCount; i++) {
        board[i][j] = random.nextInt(candyTypes);
      }
    }
  }

  // Permet de swapper deux candies si elles sont adjacentes
  void _swapCandies(Pair a, Pair b) {
    int temp = board[a.row][a.col];
    board[a.row][a.col] = board[b.row][b.col];
    board[b.row][b.col] = temp;
  }

  bool _isAdjacent(Pair a, Pair b) {
    int dRow = (a.row - b.row).abs();
    int dCol = (a.col - b.col).abs();
    return (dRow == 1 && dCol == 0) || (dRow == 0 && dCol == 1);
  }

  // Lorsqu'une case est tapée, on gère la sélection puis le swap si une deuxième case adjacente est tapée
  void _onCandyTap(int row, int col) {
    if (isGameOver) return;
    Pair tapped = Pair(row, col);
    setState(() {
      if (selectedCandy == null) {
        selectedCandy = tapped;
      } else {
        if (_isAdjacent(selectedCandy!, tapped)) {
          _swapCandies(selectedCandy!, tapped);
          // Vérifie si le swap a créé un match sur l'une ou l'autre case
          if (_hasMatchAt(selectedCandy!) || _hasMatchAt(tapped)) {
            _clearMatches();
          } else {
            // Si aucun match n'est trouvé, on annule le swap après un court délai
            Future.delayed(const Duration(milliseconds: 300), () {
              setState(() {
                _swapCandies(selectedCandy!, tapped);
              });
            });
          }
        }
        selectedCandy = null;
      }
    });
  }

  // Vérifie s'il y a un match sur la case donnée
  bool _hasMatchAt(Pair pos) {
    int type = board[pos.row][pos.col];
    // Vérification horizontal
    int count = 1;
    int col = pos.col - 1;
    while (col >= 0 && board[pos.row][col] == type) {
      count++;
      col--;
    }
    col = pos.col + 1;
    while (col < gridSize && board[pos.row][col] == type) {
      count++;
      col++;
    }
    if (count >= 3) return true;

    // Vérification vertical
    count = 1;
    int row = pos.row - 1;
    while (row >= 0 && board[row][pos.col] == type) {
      count++;
      row--;
    }
    row = pos.row + 1;
    while (row < gridSize && board[row][pos.col] == type) {
      count++;
      row++;
    }
    return count >= 3;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jeu Candy Avancé'),
        backgroundColor: Colors.deepPurple,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(child: Text('Temps: $timerSeconds s')),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(child: Text('Score: $score')),
          ),
        ],
      ),
      body: isGameOver
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Fin de la partie !',
                      style: TextStyle(fontSize: 32)),
                  const SizedBox(height: 20),
                  Text('Score final : $score',
                      style: const TextStyle(fontSize: 24)),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        score = 0;
                        isGameOver = false;
                        _initializeBoard();
                        _startTimer();
                      });
                    },
                    child: const Text('Rejouer'),
                  )
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: AspectRatio(
                aspectRatio: 1,
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: gridSize,
                  ),
                  itemCount: gridSize * gridSize,
                  itemBuilder: (context, index) {
                    int row = index ~/ gridSize;
                    int col = index % gridSize;
                    bool isSelected = selectedCandy != null &&
                        selectedCandy!.row == row &&
                        selectedCandy!.col == col;
                    return GestureDetector(
                      onTap: () => _onCandyTap(row, col),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: getCandyColor(board[row][col]),
                          border: isSelected
                              ? Border.all(color: Colors.white, width: 3)
                              : null,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
    );
  }
}

class Pair {
  final int row;
  final int col;
  Pair(this.row, this.col);
}
