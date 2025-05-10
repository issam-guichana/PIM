import 'package:flutter/material.dart';
import 'package:pim_project/Models/LoginModel.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

 Future<bool> login(String email, String password) async {
  try {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final response = await http.post(
      Uri.parse('http://10.0.2.2:3000/user/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}'); // Ajoutez ce log

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = json.decode(response.body);
      _user = User.fromJson(data['user']); // Assurez-vous de récupérer l'utilisateur
      return true; // Connexion réussie
    } else {
      _error = 'Invalid credentials';
      return false; // Connexion échouée
    }
  } catch (e) {
    _error = e.toString();
    return false; // Connexion échouée
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void logout() {
    _user = null;
    notifyListeners();
  }
}