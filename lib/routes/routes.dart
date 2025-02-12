import 'package:flutter/material.dart';
import 'package:pim_project/Views/HomePages/PatientHomePage.dart';
import '../Views/Auth/LoginScreen.dart';
import '../Views/HomePages/ParentHomePage.dart';
import '../Views/IntroPages/FirstIntroPage.dart';
import '../Views/IntroPages/SecondIntroPage.dart'; // Chemin vers votre écran de connexion

class AppRoutes {
  static const String login = '/login';
  static const String HomePatient = '/HomePagePatient';
  static const String firstIntro = '/firstIntro';
  static const String secondIntro = '/secondIntro';
  
  static const String HomeParent= '/HomePageParent';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      firstIntro: (context) => const FirstIntroScreen(),
      secondIntro: (context) => const SecondIntroScreen(),
      login: (context) => const LoginScreen(),
      HomePatient: (context) => const  HomePagePatient(),
       HomeParent: (context) => const  HomePageParent(),

    };
  }
}