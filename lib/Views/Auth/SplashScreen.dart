import 'package:flutter/material.dart';
import 'dart:async';

import 'package:version1/Routes/app_routes.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacementNamed(AppRoutes.firstIntro);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 219, 170, 255),
              Color.fromARGB(255, 149, 93, 206),
            ],
          ),
        ),
        child: Center(
          child: Image.asset(
            'assets/splash_image.png',
            width: 500,
          ),
        ),
      ),
    );
  }
}
