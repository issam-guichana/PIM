import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pim_project/Controllers/ProfileController.dart';
import 'package:pim_project/Models/LoginModel.dart';
import 'package:pim_project/routes/routes.dart';
import 'package:provider/provider.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _error;
  String? _successMessage;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get successMessage => _successMessage;

  Future<bool> login(String? email, String? password, BuildContext context) async {
    if (email == null || email.isEmpty || password == null || password.isEmpty) {
      _error = "Email and password cannot be empty";
      notifyListeners();
      return false;
    }

    try {
      _isLoading = true;
      _error = null;
      _successMessage = null;
      notifyListeners();

      final response = await http.post(
        Uri.parse('http://192.168.137.51:3000/user/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      // Handle the response
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);

        if (data['user'] == null || data['user']['id'] == null) {
          _error = "Invalid response from server";
          notifyListeners();
          return false;
        }

        _user = User.fromJson(data['user']);
        print("User role: ${_user?.role}");

        // Fetch User Profile After Login
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_user?.id != null) {
            Provider.of<ProfileProvider>(context, listen: false)
                .fetchUserProfile(_user!.id!);
          }

          _successMessage = "✅ Login successful!";
          notifyListeners();

          // Redirection vers la page Health après connexion
          Navigator.pushReplacementNamed(context, AppRoutes.health);
        });

        return true;
      } else {
        _error = 'Invalid credentials';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = "Login error: $e";
      notifyListeners();
      return false;
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
