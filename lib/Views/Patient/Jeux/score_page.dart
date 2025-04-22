import 'dart:math';
import 'dart:ui' as ui;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ScoreScreen extends StatelessWidget {
  const ScoreScreen({
    super.key,
    required this.result,
    this.historyScores = const <HistoryScore>[],
  });

  final Map<String, dynamic> result;
  final List<HistoryScore> historyScores;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final success = result['success'] as int;
    final points = result['points'] as int;
    final validity = result['details']['validity'] as int;
    final order = result['details']['order'] as int;

    final values = historyScores.isEmpty
        ? _fakeHistory(points)
        : historyScores.take(8).toList();

    final spots = [
      for (var i = 0; i < values.length; i++)
        FlSpot(i.toDouble(), values[i].value.toDouble()),
      FlSpot(values.length.toDouble(), points.toDouble()),
    ];

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary.withOpacity(.92),
                    theme.colorScheme.primary.withOpacity(.65),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'Vous avez obtenu un score de',
                    style: theme.textTheme.titleMedium!
                        .copyWith(color: Colors.white),
                  ),
                  Text(
                    '$points',
                    style: const TextStyle(
                      fontSize: 64,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      shadows: [Shadow(offset: Offset(2, 2), blurRadius: 3)],
                    ),
                  ),
                  const SizedBox(height: 16),

                  Expanded(
                    child: Row(
                      children: [
                        Expanded(child: _PostIt(validity, order, success)),
                        const SizedBox(width: 16),
                        Expanded(child: _HistoryChart(values: values, points: points)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(width: 2),
                    ),
                    child: const Text(
                      'Recommençons pour améliorer votre score !',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 28),

                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: _btn(theme),
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Continuer'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          style: _btn(theme),
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Changer d’exercice"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static ButtonStyle _btn(ThemeData t) => ElevatedButton.styleFrom(
        backgroundColor: t.colorScheme.primary,
        minimumSize: const Size.fromHeight(48),
      );

  static List<HistoryScore> _fakeHistory(int last) {
    final rnd = Random();
    return List.generate(
      7,
      (_) => HistoryScore(max(20, last - 80 + rnd.nextInt(120)), isNext: rnd.nextBool()),
    );
  }
}

class HistoryScore {
  final int value;
  final int level;
  final bool isNext;

  HistoryScore(this.value, {this.level = 1, this.isNext = false});
}

class _PostIt extends StatelessWidget {
  const _PostIt(this.validity, this.order, this.success);
  final int validity, order, success;

  @override
  Widget build(BuildContext context) => Stack(
        alignment: Alignment.center,
        children: [
          Image.asset('assets/quiz/ui/postit.png', fit: BoxFit.contain),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Validité des réponses :\n$validity %',
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Ordre des réponses :\n$order %',
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Positioned(
            top: 12,
            right: 12,
            child: CircleAvatar(
              radius: 27,
              backgroundColor: success >= 75
                  ? Colors.green
                  : (success >= 50 ? Colors.orange : Colors.red),
              child: Text(
                '$success %',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      );
}

class FlStarPainter extends FlDotPainter {
  final ui.Image starImage;

  FlStarPainter(this.starImage);

  @override
  void draw(Canvas canvas, FlSpot spot, Offset offset) {
    final src = Rect.fromLTWH(0, 0, starImage.width.toDouble(), starImage.height.toDouble());
    final dst = Rect.fromCenter(center: offset, width: 24, height: 24);
    canvas.drawImageRect(starImage, src, dst, Paint());
  }

  @override
  Size getSize(FlSpot spot) => const Size(24, 24);

  @override
  List<Object?> get props => [starImage];
}


class _HistoryChart extends StatelessWidget {
  const _HistoryChart({required this.values, required this.points});
  final List<HistoryScore> values;
  final int points;

  @override
  Widget build(BuildContext context) {
    final prim = Theme.of(context).colorScheme.primary;

    final spots = [
      for (var i = 0; i < values.length; i++)
        FlSpot(i.toDouble(), values[i].value.toDouble()),
      FlSpot(values.length.toDouble(), points.toDouble()),
    ];

    return FutureBuilder<ui.Image>(
      future: _loadStarImage(),
      builder: (context, snapshot) {
        final starImage = snapshot.data;

        return LineChart(
          LineChartData(
            backgroundColor: Colors.white,
            titlesData: const FlTitlesData(show: false),
            gridData: const FlGridData(show: false),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                isCurved: true,
                spots: spots,
                color: prim,
                barWidth: 2,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, index, bar, _) {
                    final i = spot.x.toInt();
                    final isLast = i == values.length;
                    final isNext = !isLast && values[i].isNext;

                    if (isNext && starImage != null) {
                      return FlStarPainter(starImage);
                    }
                    return FlDotCirclePainter(radius: 4, color: prim, strokeWidth: 0);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<ui.Image> _loadStarImage() async {
    final data = await rootBundle.load('assets/icon_star.png');
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    return frame.image;
  }
}