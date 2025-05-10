import 'package:flutter/material.dart';
import 'package:pim_project/Controllers/AuthProviders/AuthProvider.dart';
// Importation du ProfileController
import 'package:pim_project/Views/Auth/SplashScreen.dart';
import 'package:provider/provider.dart';
import 'routes/routes.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()), // Fournisseur pour l'authentification
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Supprime le badge de mode debug
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple), // Définir le thème avec une couleur de base
        useMaterial3: true, // Utilisation du Material Design 3
      ),
      initialRoute: '/', // Route initiale
      routes: {
        '/': (context) => const SplashScreen(), // Écran de démarrage
        ...AppRoutes.getRoutes(), // Récupération de toutes les routes définies
      },
    );
  }
}