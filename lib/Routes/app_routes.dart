import 'package:flutter/material.dart';
import 'package:version1/Views/Auth/SplashScreen.dart';
import 'package:version1/Views/Auth/first_intro_screen.dart';
import 'package:version1/Views/Auth/second_intro_screen.dart';
import 'package:version1/Views/Auth/singin.dart';
import 'package:version1/Views/Patient/HomePagePatient.dart';
import 'package:version1/Views/Profile/ChangePasswordScreen.dart';
import 'package:version1/Views/Profile/EditProfile.dart';


class AppRoutes {
  static const String splash = '/';
  static const String firstIntro = '/firstIntro';
  static const String secondIntro = '/secondIntro';
  static const String singin = '/NeonLoginScreen';
  static const String HomePatient = '/HomePagePatient';
  static const String editProfile = '/editProfile';
  static const String changePassword = '/changePassword';
  static const String avatarLauncher = '/avatarLauncher';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return _slideRoute(const SplashScreen());
      case firstIntro:
        return _slideRoute(IntroScreen());
      case secondIntro:
        return _slideRoute(const SecondIntroScreen());
      case singin:
        return _slideRoute(const NeonLoginScreen());
      case HomePatient:
        return _slideRoute(const HomePagePatient());
      case editProfile:
        return _slideRoute(const EditProfileDialog());
      case changePassword:
        return _slideRoute(const ChangePasswordScreen());
      
      default:
        return _slideRoute(const SplashScreen());
    }
  }

  static PageRouteBuilder _slideRoute(Widget page) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 600),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;
        final tween = Tween(begin: begin, end: end)
            .chain(CurveTween(curve: curve));
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }
}
