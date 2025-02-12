import 'package:flutter/material.dart';
import 'package:pim_project/Controllers/AuthProviders/AuthProvider.dart';
import 'package:pim_project/Views/Auth/SplashScreen.dart';
import 'package:provider/provider.dart';

import 'routes/routes.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const MyApp(),
    )
  );
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        ...AppRoutes.getRoutes(), // Ajoutez toutes les routes définies
      },
    );
  }
}