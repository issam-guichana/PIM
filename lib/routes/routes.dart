import 'package:flutter/material.dart';
import 'package:pim_project/Views/Auth/%20ForgetPasswordScreen.dart';

// Auth & Splash
import 'package:pim_project/Views/Auth/LoginScreen.dart';
import 'package:pim_project/Views/Auth/SplashScreen.dart';
import 'package:pim_project/Views/HomePages/AdviceScreen.dart';

// Intro
import 'package:pim_project/Views/IntroPages/FirstIntroPage.dart';
import 'package:pim_project/Views/IntroPages/SecondIntroPage.dart';

// Home
import 'package:pim_project/Views/HomePages/ParentHomePage.dart';
import 'package:pim_project/Views/HomePages/PatientHomePage.dart';
import 'package:pim_project/Views/HomePages/fit_screen.dart';

// Assistant Vocal
import 'package:pim_project/Views/AssitantVocal/SpeechInteractionPage.dart';
import 'package:pim_project/Views/AssitantVocal/VoiceRecordingPage.dart';

// Profile
import 'package:pim_project/Views/Profile/ChangePasswordScreen.dart';
import 'package:pim_project/Views/Profile/EditProfile.dart';
import 'package:pim_project/Views/Profile/ProfileScreen.dart';

class AppRoutes {
  static const String login = '/login';
  static const String homePatient = '/homePagePatient';
  static const String homeParent = '/homePageParent';
  static const String health = '/health';
  static const String healthHistory = '/healthHistory';
  static const String assistantVocal = '/assistantVocal';
  static const String recordVocal = '/recordVocal';
  static const String profile = '/profile';
  static const String editProfile = '/editProfile';
  static const String changePassword = '/changePassword';
  static const String forgotPassword = '/forgotPassword';
  static const String firstIntro = '/firstIntro';
  static const String secondIntro = '/secondIntro';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case firstIntro:
        return MaterialPageRoute(builder: (_) => const FirstIntroScreen());

      case secondIntro:
        return MaterialPageRoute(builder: (_) => const SecondIntroScreen());

      case homePatient:
        return MaterialPageRoute(builder: (_) => const HomePagePatient());

      case homeParent:
        return MaterialPageRoute(builder: (_) => const HomePageParent());

      case assistantVocal:
        return MaterialPageRoute(builder: (_) => const SpeechInteractionPage());

      case recordVocal:
        return MaterialPageRoute(builder: (_) => VoiceRecordingPage());

      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());

      case editProfile:
        return MaterialPageRoute(builder: (_) => const EditProfileScreen());

      case changePassword:
        return MaterialPageRoute(builder: (_) => const ChangePasswordScreen());

      case forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgetPasswordDialog());

      case health:
        final args = settings.arguments;
        if (args is Map<String, dynamic> &&
            args.containsKey('fitData') &&
            args.containsKey('accessToken')) {
          return MaterialPageRoute(
            builder: (_) => FitScreen(
              fitData: args['fitData'],
              accessToken: args['accessToken'],
            ),
          );
        } else {
          return MaterialPageRoute(
            builder: (_) => const Scaffold(
              body: Center(
                child: Text("❌ Données Google Fit non disponibles."),
              ),
            ),
          );
        }

      case '/advice':
        final fitData = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => AdviceScreen(fitData: fitData, advice: ''),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text(
                "Page non trouvée ❌",
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
        );
    }
  }
}
