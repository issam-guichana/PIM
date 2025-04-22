// lib/Views/Patient/Jeux/QuizPage.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:version1/Models/games_logic/quiz_engine.dart';
import 'package:version1/Models/games_logic/quiz_question.dart';
import 'package:version1/Views/Patient/Jeux/score_page.dart';

// ────────────────────────────────────────────────────────────────
enum _Phase { qcm, order }                     // résultat déplacé dans ScoreScreen
// ────────────────────────────────────────────────────────────────

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});
  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  late Future<void> _loader;
  late QuizEngine   _engine;
  _Phase            _phase = _Phase.qcm;

  @override
  void initState() {
    super.initState();
    _loader = _initGame();
  }

  Future<void> _initGame() async {
    final qs   = await QuizService().loadQuestions();
    final cats = {for (var q in qs) q.id.substring(0, 4): q.id.substring(0, 4)};

    _engine = QuizEngine(qs, cats)..init();
    _engine.loadLevel(1);                           // ← 2 questions
    _engine.start();
  }

  // ─────────────────────────── phase 1 – QCM
  bool get _hasAnswer =>
      _engine.quickAnswers[_engine.current]?.r.isNotEmpty ?? false;

  void _chooseQcm(String l) =>
      setState(() => _engine.quickAnswer(l));

  void _continueQcm() {
    _engine.next();
    if (_engine.current >= _engine.quiz.length) {
      setState(() {
        _phase           = _Phase.order;
        _engine.current  = 0;
      });
    } else {
      setState(() {});
    }
  }

  // ─────────────────────────── phase 2 – ordre
  void _chooseOrder(int q, String r) =>
      setState(() => _engine.toggleAnswer(q, r));

  bool get _orderComplete =>
      _engine.answered.length == _engine.quiz.length;

  void _finishGame() {
    final res = _engine.end();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => ScoreScreen(result: res)),
    );
  }

  // ─────────────────────────── BUILD
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Quiz MeMo'),
          backgroundColor: const Color(0xFF723D92),
        ),
        body: FutureBuilder(
          future: _loader,
          builder: (_, s) {
            if (s.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            return _phase == _Phase.qcm ? _buildQcm() : _buildOrder();
          },
        ),
      );

  // ─────────────────────────── UI – phase 1
  Widget _buildQcm() {
    final q       = _engine.quiz[_engine.current];
    final letters = _engine.letters;
    final sel     = _engine.quickAnswers[_engine.current]?.r;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text('${_engine.current + 1}. ${q.text}',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center),
          const SizedBox(height: 24),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: letters.map((l) {
                final txt    = q.answers[l]!;
                final chosen = sel == l;
                final isImg  = q.imgExt != null;
                final path   = 'assets/quiz/images/${q.cat}_${txt}.${q.imgExt ?? ''}';

                return GestureDetector(
                  onTap: () => _chooseQcm(l),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: chosen ? Colors.deepPurple : Colors.grey.shade400,
                        width: chosen ? 4 : 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: isImg
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset(path, fit: BoxFit.contain),
                          )
                        : Center(
                            child: Padding(
                              padding: const EdgeInsets.all(6),
                              child: Text(txt,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 20)),
                            ),
                          ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _hasAnswer ? _continueQcm : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF723D92),
              minimumSize: const Size.fromHeight(48),
            ),
            child: Text(_engine.current == _engine.quiz.length - 1
                ? 'Mémorisé !'
                : 'Continuer'),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────── UI – phase 2
  Widget _buildOrder() {
    final tiles = _engine.answersTab;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            'Dans l’ordre, quelle était la réponse à la question '
            '${_engine.current + 1} ?',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Expanded(
            child: GridView.count(
              crossAxisCount: (_engine.quiz.length >= 7) ? 3 : 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              children: tiles.map((qa) {
                final q     = _engine.quiz[qa.q];
                final txt   = q.answers[qa.r]!;
                final isImg = q.imgExt != null;
                final path  = 'assets/quiz/images/${q.cat}_${txt}.${q.imgExt ?? ''}';
                final chosen = _engine.answered.any((e) => e.q == qa.q && e.r == qa.r);

                return Opacity(
                  opacity: chosen ? .25 : 1,
                  child: GestureDetector(
                    onTap: () => _chooseOrder(qa.q, qa.r),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400, width: 2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: isImg
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(path, fit: BoxFit.contain),
                            )
                          : Center(
                              child: Padding(
                                padding: const EdgeInsets.all(4),
                                child: Text(txt,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 18)),
                              ),
                            ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _orderComplete ? _finishGame : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF723D92),
              minimumSize: const Size.fromHeight(48),
            ),
            child: const Text('Valider ces réponses'),
          ),
        ],
      ),
    );
  }
}
