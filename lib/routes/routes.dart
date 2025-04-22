import 'package:flutter/material.dart';
import 'package:tesst1/Auth/LoginScreen.dart';
import 'package:tesst1/Auth/register_screen.dart';
import 'package:tesst1/HomePages/ParentHomePage.dart';
import 'package:tesst1/HomePages/PatientHomePage.dart';
import 'package:tesst1/Views/Chat/ChatScreen.dart';
import 'package:tesst1/Views/IntroPages/SecondIntroPage.dart';
import 'package:tesst1/views/IntroPages/FirstIntroPage.dart';
import 'package:tesst1/Views/Chat/ChatScreen.dart';
//import 'package:tesst1/views/call/CallHistoryScreen.dart';

class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String homePatient = '/HomePagePatient';
  static const String firstIntro = '/firstIntro';
  static const String secondIntro = '/secondIntro';
  static const String editProfile = '/editProfile';
  static const String profile = '/profile';
  static const String homeParent = '/HomePageParent';
  static const String changePassword = '/changePassword';
  static const String forgotPassword =
      '/ForgetPasswordScreen'; // ✅ Définir la route correctement
  static const String avatarScreen = '/avatarScreen';
  static const String chat = '/chat';
  static const String callHistory = '/callHistory';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      firstIntro: (context) => const FirstIntroScreen(),
      secondIntro: (context) => const SecondIntroScreen(),
      login: (context) => const LoginScreen(),
      register: (context) => const RegisterScreen(),
      homePatient: (context) => const HomePagePatient(),
      homeParent: (context) => const HomePageParent(),
      chat: (context) => const ChatScreen(),
      // callHistory: (context) => const CallHistoryScreen(),
    };
  }
}
