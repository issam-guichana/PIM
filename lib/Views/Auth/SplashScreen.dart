import 'dart:async';
import 'package:flutter/material.dart';
import '../../routes/routes.dart'; // Assurez-vous d'importer le bon fichier de routes

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  @override
void initState() {
  super.initState();
  Timer(const Duration(seconds: 2), () {
    Navigator.pushReplacementNamed(context, AppRoutes.firstIntro); // Naviguer vers la première page d'intro
  });
}
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset(
          'Assets/SplashScreen/splash_image.png',
          width: screenWidth * 0.9,
          height: screenHeight * 0.8,
        ),
      ),
    );
  }
}