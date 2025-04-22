import 'dart:async';
import 'package:flutter/material.dart';
import '../../routes/routes.dart'; // Assurez-vous d'importer le bon fichier de routes

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer; // Declare a Timer variable to manage the splash screen duration

  @override
  void initState() {
    super.initState();

    // Set a timer to navigate to the next screen after 2 seconds
    _timer = Timer(const Duration(seconds: 2), () {
      Navigator.pushReplacementNamed(context, AppRoutes.firstIntro); // Naviguer vers la première page d'intro
    });
  }

  @override
  void dispose() {
    // Cancel the timer when the widget is disposed to avoid memory leaks
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset(
          'assets/splash_image.png', // Ensure this path is correct and added to pubspec.yaml
          width: screenWidth * 0.9,
          height: screenHeight * 0.8,
          errorBuilder: (context, error, stackTrace) {
            // Handle errors if the image fails to load
            return const Text(
              'Erreur de chargement de l\'image',
              style: TextStyle(color: Colors.red, fontSize: 16),
            );
          },
        ),
      ),
    );
  }
}