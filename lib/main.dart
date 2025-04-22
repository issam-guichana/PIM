import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'; // Import local notifications
import 'package:tesst1/Auth/SplashScreen.dart';
import 'package:tesst1/Controllers/AuthProviders.dart';

import 'routes/routes.dart';

// Initialize FlutterLocalNotificationsPlugin
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  // Ensure Flutter bindings are initialized before running the app
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize local notifications
  await _initializeLocalNotifications();

  // Request permissions
  await requestPermissions();

  // Run the app with providers
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProviders()),
      ],
      child: const MyApp(),
    ),
  );
}

Future<void> _initializeLocalNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings(
          '@mipmap/ic_launcher'); // Set your icon here

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
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
        ...AppRoutes
            .getRoutes(), // Spread operator to include additional routes
      },
    );
  }
}

/// Request necessary permissions and handle the result
Future<void> requestPermissions() async {
  // Microphone Permission
  final micStatus = await Permission.microphone.request();
  if (micStatus.isGranted) {
    print("✅ Microphone permission granted");
  } else if (micStatus.isDenied) {
    print("❌ Microphone permission denied");
  } else if (micStatus.isPermanentlyDenied) {
    print(
        "❌ Microphone permission permanently denied. Please enable it in settings.");
    openAppSettings();
  }

  // Notification Permission (Android 13+)
  final notifStatus = await Permission.notification.request();
  if (notifStatus.isGranted) {
    print("✅ Notification permission granted");
  } else if (notifStatus.isDenied) {
    print("❌ Notification permission denied");
  } else if (notifStatus.isPermanentlyDenied) {
    print(
        "❌ Notification permission permanently denied. Please enable it in settings.");
    openAppSettings();
  }

  // Optionally, if notifications are granted, you could schedule a test notification.
  if (notifStatus.isGranted) {
    await _showTestNotification();
  }
}

// Display a test notification once permissions are granted
Future<void> _showTestNotification() async {
  const AndroidNotificationDetails androidNotificationDetails =
      AndroidNotificationDetails(
    'test_channel', // Channel ID
    'Test Notifications', // Channel Name
    channelDescription: 'This is a test channel for notifications',
    importance: Importance.high,
    priority: Priority.high,
  );

  const NotificationDetails notificationDetails = NotificationDetails(
    android: androidNotificationDetails,
  );

  await flutterLocalNotificationsPlugin.show(
    0,
    'Test Notification',
    'Your permissions are set up!',
    notificationDetails,
  );
}
