import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pim_project/Controllers/AuthProvider.dart';
import 'package:pim_project/Controllers/fit_provider.dart';
import 'package:pim_project/Controllers/ProfileController.dart';
import 'package:pim_project/routes/routes.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => FitProvider()),
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
      title: 'PIM Project',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/',
      onGenerateRoute: AppRoutes.generateRoute,
      
    );
  }
}
