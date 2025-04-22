import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

/// ---------------------------
///  Modèle Question
/// ---------------------------
class Question {
  final String id;
  final String text;
  final String a, b, c;
  final String? d;
  final bool only4;
  final String? imgExt;
  late final String cat; // 4 premiers chars de l’id

  Question({
    required this.id,
    required this.text,
    required this.a,
    required this.b,
    required this.c,
    this.d,
    this.only4 = false,
    this.imgExt,
  }) {
    cat = id.substring(0, 4);
  }

  factory Question.fromJson(Map<String, dynamic> j) => Question(
        id: j['id'] as String,
        text: j['text'] as String,
        a: j['a'] as String,
        b: j['b'] as String,
        c: j['c'] as String,
        d: j['d'] as String?,
        only4: j['only4'] as bool? ?? false,
        imgExt: j['img'] as String?,
      );

  Map<String, String> get answers => {
        'a': a,
        'b': b,
        'c': c,
        if (d != null) 'd': d!,
      };
}

/// ---------------------------
///  Paire Question / Réponse
/// ---------------------------
class QA {
  QA(this.q, this.r);
  final int q;      // index dans quiz[]
  final String r;   // a|b|c|d
}

/// ---------------------------
///  Service JSON
/// ---------------------------
class QuizService {
  Future<List<Question>> loadQuestions() async {
    final raw = await rootBundle.loadString(
      'assets/quiz/data/questions.json',
    );
    final List data = jsonDecode(raw) as List;
    return data.map((e) => Question.fromJson(e)).toList();
  }
}
