import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pim_project/main.dart';

void main() {
  testWidgets('SplashScreen appears on launch', (WidgetTester tester) async {
    // Lance l'application
    await tester.pumpWidget(const MyApp());

    // Attend que la frame soit dessinée
    await tester.pumpAndSettle();

    // Vérifie que le SplashScreen est visible
    expect(find.textContaining('Santé'), findsOneWidget); // Ajuste le texte si nécessaire
  });
}
