import 'package:flutter/material.dart';
import 'package:pim_project/Views/AssitantVocal/SpeechInteractionPage.dart';
import 'package:pim_project/Views/AssitantVocal/VoiceRecordingPage.dart';
import 'package:pim_project/Views/Auth/%20ForgetPasswordScreen.dart';
import 'package:pim_project/Views/HomePages/PatientHomePage.dart';
import 'package:pim_project/Views/HomePages/health_history.dart';

import 'package:pim_project/Views/HomePages/health_screen.dart';
import 'package:pim_project/Views/Profile/ChangePasswordScreen.dart';
import 'package:pim_project/Views/Profile/EditProfile.dart';
import 'package:pim_project/Views/Profile/ProfileScreen.dart';


import '../Views/Auth/LoginScreen.dart';
import '../Views/HomePages/ParentHomePage.dart';
import '../Views/IntroPages/FirstIntroPage.dart';
import '../Views/IntroPages/SecondIntroPage.dart';

class AppRoutes {
  static const String login = '/login';
  static const String homePatient = '/homePagePatient';
  static const String firstIntro = '/firstIntro';
  static const String secondIntro = '/secondIntro';
  static const String homeParent = '/homePageParent';
  static const String health = '/health';
  static const String healthHistory = '/healthHistory'; 
  static const String assistantVocal = '/assistantVocal'; 
  static const String RecordVocal = '/RecordVocal'; 
  static const String profile = '/profile';
  static const String editProfile = '/editProfile';
  static const String changePassword = '/changePassword';
  static const String forgotPassword = '/ForgetPasswordScreen'; 
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      firstIntro: (context) => const FirstIntroScreen(),
      secondIntro: (context) => const SecondIntroScreen(),
      login: (context) => const LoginScreen(),
      homePatient: (context) => const HomePagePatient(),
      homeParent: (context) => const HomePageParent(),
      health: (context) => const HealthScreen(),
      healthHistory: (context) => HealthHistoryScreen(),
      assistantVocal: (context) => const SpeechInteractionPage(),
      RecordVocal: (context) => VoiceRecordingPage(),
      profile: (context) => const ProfileScreen(),
      editProfile: (context) => const EditProfileScreen(),
      changePassword: (context) => const ChangePasswordScreen(),
      forgotPassword: (context) => const ForgetPasswordDialog(), // ✅ Ajouter la route ici



    
    };
  }
}

