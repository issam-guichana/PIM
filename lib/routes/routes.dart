import 'package:flutter/material.dart';
import 'package:tesst1/Views/Auth/%20ForgetPasswordScreen.dart';
import 'package:tesst1/Views/Auth/LoginScreen.dart';
import 'package:tesst1/Views/HomePages/ParentHomePage.dart';
import 'package:tesst1/Views/HomePages/PatientHomePage.dart' show HomePagePatient;
import 'package:tesst1/Views/IntroPages/FirstIntroPage.dart';
import 'package:tesst1/Views/IntroPages/SecondIntroPage.dart';
import 'package:tesst1/Views/Profile/ChangePasswordScreen.dart';
import 'package:tesst1/Views/Profile/EditProfile.dart';
import 'package:tesst1/Views/Profile/ProfileScreen.dart';



class AppRoutes {
  static const String login = '/login';
  static const String homePatient = '/HomePagePatient';
  static const String firstIntro = '/firstIntro';
  static const String secondIntro = '/secondIntro';
  static const String editProfile = '/editProfile';
  static const String profile = '/profile';
  static const String homeParent = '/HomePageParent';
  static const String changePassword = '/changePassword';
  static const String forgotPassword = '/ForgetPasswordScreen'; // ✅ Définir la route correctement
  static const String avatarScreen = '/avatarScreen';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      firstIntro: (context) => const FirstIntroScreen(),
      secondIntro: (context) => const SecondIntroScreen(),
      login: (context) => const LoginScreen(),
      homePatient: (context) => const HomePagePatient(),
      homeParent: (context) => const HomePageParent(),
      profile: (context) => const ProfileScreen(),
      editProfile: (context) => const EditProfileScreen(),
      changePassword: (context) => const ChangePasswordScreen(),
      forgotPassword: (context) => const ForgetPasswordDialog(), // ✅ Ajouter la route ici

      
    };
  }
}
