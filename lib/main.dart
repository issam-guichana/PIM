import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:tesst1/Controllers/AuthProvider.dart';
import 'package:tesst1/Controllers/ProfileController.dart';
import 'package:tesst1/Controllers/avatarProvider.dart';
import 'package:tesst1/Views/Auth/SplashScreen.dart';
import 'routes/routes.dart';

Future<void> main() async {
  // Ensure Flutter bindings are initialized before running the app
  WidgetsFlutterBinding.ensureInitialized();

  // Request microphone permission
  await requestMicrophonePermission();

  // Run the app with providers
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
                ChangeNotifierProvider(create: (_) => AvatarProvider()),


      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Remove the debug banner
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/', // Set the initial route
      routes: {
        '/': (context) => const SplashScreen(), // Default route to SplashScreen
        ...AppRoutes.getRoutes(), // Spread operator to include additional routes
      },
    );
  }
}

/// Request microphone permission and handle the result
Future<void> requestMicrophonePermission() async {
  final status = await Permission.microphone.request();
  if (status.isGranted) {
    print("✅ Microphone permission granted");
  } else if (status.isDenied) {
    print("❌ Microphone permission denied");
  } else if (status.isPermanentlyDenied) {
    print("❌ Microphone permission permanently denied. Please enable it in settings.");
    // Optionally, open app settings to allow the user to grant permission manually
    openAppSettings();
  }
}