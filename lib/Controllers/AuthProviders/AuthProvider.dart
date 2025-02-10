import 'package:flutter/material.dart';
import 'package:pim_project/Models/LoginModel.dart';



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

      // Simulate API call with delay
      await Future.delayed(Duration(seconds: 2));

      // Replace this with your actual API call
      if (email == "test@test.com" && password == "password") {
        _user = User(email: email, token: "dummy_token");
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        throw Exception('Invalid credentials');
      }
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
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
