import 'dart:math';

import 'package:version1/Models/games_logic/quiz_question.dart';

// ==== petits helpers =========================================================
final _rng = Random();
void _shuffle<T>(List<T> l) {
  for (var i = l.length - 1; i > 0; i--) {
    final j = _rng.nextInt(i + 1);
    final tmp = l[i]; l[i] = l[j]; l[j] = tmp;
  }
}
int _lev(String s, String t) {                    // Levenshtein
  if (s == t) return 0;
  if (s.isEmpty) return t.length;
  if (t.isEmpty) return s.length;
  final v0 = List<int>.generate(t.length + 1, (i) => i);
  final v1 = List<int>.filled(t.length + 1, 0);

  for (var i = 0; i < s.length; i++) {
    v1[0] = i + 1;
    for (var j = 0; j < t.length; j++) {
      final cost = s[i] == t[j] ? 0 : 1;
      v1[j + 1] = [
        v1[j] + 1,
        v0[j + 1] + 1,
        v0[j] + cost,
      ].reduce(min);
    }
    for (var j = 0; j < v0.length; j++) {
      v0[j] = v1[j];
    }
  }
  return v1[t.length];
}
// =============================================================================

class QuizEngine {
  // -------------------- données de base --------------------
  final List<Question> _all;
  final Map<String, String> _cats;

  QuizEngine(this._all, this._cats) {
    if (_all.isEmpty) throw StateError('questions manquantes');
    if (_cats.isEmpty) throw StateError('catégories manquantes');
  }

  // ----------------- configuration par niveau --------------
  final List<Map<String, int>> _levels = [
    {'nb': 2}, {'nb': 3}, {'nb': 4}, {'nb': 5},
    {'nb': 6}, {'nb': 7}, {'nb': 8}, {'nb': 9},
  ];

  // ---------------- état de la partie courante -------------
  late Map<String, dynamic> lvl;      // nb, categories, nbProps
  late List<Question> quiz;           // tirage
  late List<String> letters;          // ['a','b','c','d'] ou 3 lettres
  late List<QA> answersTab;           // tableau des 12 / 24 cases
  late List<QA?> quickAnswers;        // phase 1
  late List<QA> answered;             // phase 2 (ordre)
  late DateTime started;

  int current = 0;                    // index question affichée
  String mode = 'normal';             // 'simple' (nb=1) ou 'normal'

  final _seenCats   = <String>[];               // anti‑répétition
  final _seenQByCat = <String, List<String>>{}; //

  // ---------------------------------------------------------------------------
  // loadLevel  (level : 1‑8 ou 0 pour « custom »)
  // ---------------------------------------------------------------------------
  String? loadLevel(int level,
      {Map<String, dynamic>? params, Map<String, dynamic>? special}) {
    if (level == 0 && params == null) return 'params manquants';

    if (level == 0) {
      lvl = {
        'nb':        params!['nb'] as int,
        'categories': List<String>.from(params['categories'] as List),
      };
    } else {
      lvl = Map<String, dynamic>.from(_levels[level - 1]);
      lvl['categories'] = _cats.keys.toList();
    }
    if (lvl['nb'] > (lvl['categories'] as List).length) {
      return 'Il faut plus de catégories que de questions';
    }

    // récupère l’historique éventuel
    if (special != null) {
      _seenCats.addAll(List<String>.from(special['seenCategories'] ?? []));
      final m = special['seenQuestions'] as Map<String, dynamic>? ?? {};
      m.forEach((k, v) =>
          _seenQByCat.putIfAbsent(k, () => []).addAll(List<String>.from(v)));
    }
    return null; // OK
  }

  // ---------------------------------------------------------------------------
  // start()    -> prépare quiz, answersTab, quickAnswers…
  // ---------------------------------------------------------------------------
  void start() {
    mode = (lvl['nb'] == 1) ? 'simple' : 'normal';
    lvl['nbProps'] = (lvl['nb'] < 7) ? 4 : 3;
    letters = ['a', 'b', 'c', 'd'].sublist(0, lvl['nbProps']);

    quiz = [];
    if (mode == 'simple') {
      // pool = toutes les questions valides
      quiz = _all.where((q) {
        final okCat = (lvl['categories'] as List).contains(q.cat);
        final okProp = lvl['nbProps'] == 4 || !q.only4;
        return okCat && okProp;
      }).toList();
      _shuffle(quiz);
      quiz = quiz.take(lvl['nb']).toList();
    } else {
      // tirage équilibré par catégories & anti‑répétitions
      var catsPool = (lvl['categories'] as List<String>)
          .where((c) => !_seenCats.contains(c))
          .toList();
      while (catsPool.length < lvl['nb']) {
        _seenCats.removeRange(0, (_seenCats.length / 2).ceil());
        catsPool = (lvl['categories'] as List<String>)
            .where((c) => !_seenCats.contains(c))
            .toList();
      }
      _shuffle(catsPool);

      for (var i = 0; i < lvl['nb']; i++) {
        final cat = catsPool.removeAt(0);
        _seenCats.add(cat);
        _seenQByCat.putIfAbsent(cat, () => []);

        // construit le pool autorisé pour cette catégorie
        final pool = <Question>[];
        final seenPool = <String, Question>{};
        int total = 0;
        for (final q in _all) {
          if (q.cat != cat) continue;
          if (_alreadyHaveSimilar(q)) continue;
          total++;
          if (!_seenQByCat[cat]!.contains(q.id))
            pool.add(q);
          else
            seenPool[q.id] = q;
        }
        if (total == 0) { i--; continue; }

        if (pool.length < max(1, (total / 4).ceil())) {
          final refill = _seenQByCat[cat]!.take((total / 2).ceil()).toList();
          _seenQByCat[cat]!.removeRange(0, refill.length);
          for (final id in refill) {
            if (seenPool.containsKey(id)) pool.add(seenPool[id]!);
          }
        }
        _shuffle(pool);
        final q = pool.removeAt(0);
        quiz.add(q);
        _seenQByCat[cat]!.add(q.id);
      }
    }

    // toutes les cases (ordre aléatoire) – pour l’écran de rappel
    answersTab = [];
    for (var i = 0; i < quiz.length; i++) {
      for (final l in letters) {
        answersTab.add(QA(i, l));
      }
    }
    _shuffle(answersTab);

    quickAnswers = List<QA?>.filled(quiz.length, null);
    answered     = [];
    current      = 0;
    started      = DateTime.now();
  }

  // ---------------------------------------------------------------------------
  // Méthodes appelées depuis l’UI
  // ---------------------------------------------------------------------------
  void quickAnswer(String letter) {
    quickAnswers[current] = QA(current, letter);
  }

  void valid() => next();             // alias (si tu en as besoin)

 // ───────────────────────────────────────── quiz_engine.dart
void next() {
  // on laisse l’index aller jusqu’à quiz.length
  if (current < quiz.length) current++;
}


  /// Lors de la phase « ordre des réponses »
  void toggleAnswer(int q, String r) {
    final idx = answered.indexWhere((e) => e.q == q && e.r == r);
    if (idx != -1) {
      answered = answered.sublist(0, idx);
      current  = answered.length;
    } else {
      answered.add(QA(q, r));
      current  = answered.length;
    }
  }
void init() {
    if (_cats.isEmpty) throw StateError('catégories manquantes');
    if (_all.isEmpty)  throw StateError('questions manquantes');
    // ici vous pouvez effectuer d’autres préparations si besoin
  }
  // ---------------------------------------------------------------------------
  // Terminaison : calcule le score final
  // ---------------------------------------------------------------------------
  Map<String, dynamic> end() {
    const pts = [100, 80, 50, 10, 0];
    double goodness = 0;

    for (var i = 0; i < lvl['nb']; i++) {
final old = quickAnswers[i]?.r ?? '';      var state = (old == 'a') ? 3 : 4;

      for (final a in answered) {
        if (a.q != i) continue;
        final right     = a.r == 'a';
        final concorde  = a.r == old;
        if (right && concorde) state = 0;
        else if (!right && concorde) state = 1;
        else if (right && !concorde) state = 2;
      }
      goodness += pts[state];
    }
    goodness /= lvl['nb'];

    final your = answered.map((e) => e.q).join();
    final ideal = List.generate(lvl['nb'], (i) => i).join();
    final dist = _lev(your, ideal);
    final order = 100 * (lvl['nb'] - dist - 1) / (lvl['nb'] - 1);
    final success = (goodness + order) / 2;
    final points  = success * lvl['nb'];

    return {
      'success': success.round(),
      'points' : points.round(),
      'details': {
        'validity': goodness.round(),
        'order'   : order.round(),
      }
    };
  }

  // ---------------------------------------------------------------------------
  bool _alreadyHaveSimilar(Question q) {
    for (final ex in quiz) {
      for (final l1 in letters) {
        for (final l2 in letters) {
          if (ex.answers[l1] == q.answers[l2]) return true;
        }
      }
    }
    return false;
  }
}
