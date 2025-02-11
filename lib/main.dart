import 'package:flutter/material.dart';
import 'package:pim_project/Controllers/AuthProviders/AuthProvider.dart';
import 'package:pim_project/Views/AuthPages/ForgotPwdScreen.dart';
import 'package:pim_project/Views/AuthPages/SplashScreen.dart';
import 'package:pim_project/Views/HomePages/PatientHomePage.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const MyApp(),
    )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home:  SplashScreen(),

      // home:  ForgotPasswordScreen() ,

    );
  }
}

