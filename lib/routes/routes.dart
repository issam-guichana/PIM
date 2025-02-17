import 'package:flutter/material.dart';
import 'package:pim_project/Views/HomePages/PatientHomePage.dart';
import '../Views/Auth/LoginScreen.dart';
import '../Views/HomePages/ParentHomePage.dart';
import '../Views/IntroPages/FirstIntroPage.dart';
import '../Views/IntroPages/SecondIntroPage.dart';
import '../Views/HomePages/FitnessScreen.dart';


class AppRoutes {
  static const String login = '/login';
  static const String HomePatient = '/HomePagePatient';
  static const String firstIntro = '/firstIntro';
  static const String secondIntro = '/secondIntro';
  static const String HomeParent = '/HomePageParent';
  static const String fitnessScreen = '/fitnessScreen'; // ✅ Ajout de la route FitnessScreen

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      firstIntro: (context) => const FirstIntroScreen(),
      secondIntro: (context) => const SecondIntroScreen(),
      login: (context) => const LoginScreen(),
      HomePatient: (context) => const HomePagePatient(),
      HomeParent: (context) => const HomePageParent(),
      fitnessScreen: (context) => const Fitnessscreen(), // ✅ Ajout de la route
    };
  }
}

