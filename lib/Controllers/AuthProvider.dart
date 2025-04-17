import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:pim_project/Models/LoginModel.dart';
import 'package:pim_project/routes/routes.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic> _fitData = {};

  // ✅ Token Google OAuth à utiliser dans FitScreen
  String? _googleAccessToken;
  String? get googleAccessToken => _googleAccessToken;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: '54497297024-aqub3nket3spntr21rd05qq4s5knct8p.apps.googleusercontent.com',
    scopes: [
      'email',
      'profile',
      'https://www.googleapis.com/auth/fitness.activity.read',
      'https://www.googleapis.com/auth/fitness.sleep.read',
      'https://www.googleapis.com/auth/fitness.heart_rate.read',
      'https://www.googleapis.com/auth/fitness.body.read',
    ],
  );

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic> get fitData => _fitData;

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<bool> login(String? email, String? password, BuildContext context) async {
    if (email == null || email.isEmpty || password == null || password.isEmpty) {
      _error = "Email et mot de passe requis";
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse(" https://6491-196-234-27-227.ngrok-free.app/api/user/login"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _user = User.fromJson(data['user']);
        notifyListeners();
        return true;
      } else {
        _error = "Email ou mot de passe incorrect";
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = "Erreur de connexion: $e";
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signInWithGoogle(BuildContext context) async {
    try {
      _isLoading = true;
      notifyListeners();

      print("🚀 Démarrage de la connexion Google...");

      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        print("❌ Connexion annulée par l'utilisateur.");
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      final accessToken = googleAuth.accessToken;

      if (idToken == null || accessToken == null) {
        print("❌ Token manquant.");
        _isLoading = false;
        notifyListeners();
        return false;
      }

      _googleAccessToken = accessToken; // ✅ On le stocke pour les appels futurs

      print("✅ Google ID Token: $idToken");
      print("✅ Google Access Token: $accessToken");

      final response = await http.post(
        Uri.parse("https://6491-196-234-27-227.ngrok-free.app/api/auth/google-login"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'idToken': idToken,
          'accessToken': accessToken,
        }),
      );

      print("📡 Réponse backend : ${response.statusCode}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        final user = data['user'];
        final fitDataFromServer = data['fitData'];

        print("✅ Utilisateur reçu : $user");
        print("✅ Données Fit : $fitDataFromServer");

        _user = User.fromJson(user);

        if (fitDataFromServer is String) {
          _fitData = json.decode(fitDataFromServer);
        } else if (fitDataFromServer is Map<String, dynamic>) {
          _fitData = fitDataFromServer;
        } else {
          _fitData = {};
        }

        notifyListeners();

        // 🕐 Attendre une micro-délai pour éviter un accès trop précoce
        await Future.delayed(Duration(milliseconds: 50));

        _isLoading = false;
        notifyListeners();

       Navigator.pushReplacementNamed(
  context,
  AppRoutes.health,
  arguments: {
    'fitData': _fitData,
    'accessToken': _googleAccessToken,
  },
);

        return true;
      } else {
        _error = "Erreur backend: ${response.body}";
        print("❌ Erreur backend: ${response.body}");
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = "Erreur lors de la connexion Google: $e";
      print("💥 Erreur exception: $e");
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}