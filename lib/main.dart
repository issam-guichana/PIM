import 'package:flutter/material.dart';
import 'Views//Auth/Watch/watch_dashboard.dart';



void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Watch Dashboard',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home:HealthDataScreen(),
    );
  }
}
