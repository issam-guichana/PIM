
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:tesst1/Controllers/ProfileController.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:convert';

// ignore: depend_on_referenced_packages
import 'package:tesst1/Models/LoginModel.dart';
import 'package:tesst1/routes/routes.dart';
import 'package:tesst1/services/socket_service.dart' show SocketService;

class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _error;
   String? _successMessage;
  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  //final BiometricAuthService _biometricAuthService = BiometricAuthService();
  final bool _isAuthenticated = false;

  bool get isAuthenticated => _isAuthenticated;

 Future<bool> login(String email, String password, BuildContext context) async {
  try {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final response = await http.post(
      Uri.parse('http://172.20.10.3:3000/user/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = json.decode(response.body);
      String token = data['access_token'];
 SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', token); // ✅ Stocker le token
        print("✅ Token JWT enregistré avec succès !");

      if (data['user'] == null || data['user']['id'] == null) {
        print("Error: Missing user data in response");
        _error = "Invalid response from server";
        notifyListeners();
        return false;
      }

      _user = User.fromJson(data['user']);
      print("User role: ${_user?.role}");

      // ✅ Fetch User Profile After Login
      Provider.of<ProfileProvider>(context, listen: false).fetchUserProfile(_user!.id);

      _successMessage = "✅ Login successful!";
      notifyListeners();

      // ✅ **Ensure Navigation Works Properly**
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_user?.role == 'user') {
          print("✅ Navigating to homePatient...");
          Navigator.pushReplacementNamed(context, AppRoutes.homePatient);
        } else if (_user?.role == 'parent') {
          print("✅ Navigating to homeParent...");
          Navigator.pushReplacementNamed(context, AppRoutes.homeParent);
        } else {
          print("❌ Unrecognized role, navigation not performed.");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("❌ Unrecognized role.")),
          );
        }
      });

      return true; // Login successful
    } else {
      _error = '❌ Invalid credentials';
      notifyListeners();
      return false;
    }
  } catch (e) {
    print("❌ Login error: $e");
    _error = e.toString();
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

 Future<void> logout() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token'); // ✅ Supprime le token lors de la déconnexion
  _user = null;
  notifyListeners();
      SocketService.disconnect();

}
Future<bool> loginWithFaceID() async {
   
    return false;
  }

}