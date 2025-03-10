
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pim_project/Controllers/ProfileController.dart';
import 'package:pim_project/Models/LoginModel.dart';
import 'package:pim_project/routes/routes.dart';
import 'package:provider/provider.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'dart:convert';



class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _error;
   String? _successMessage;
  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
    final GoogleSignIn _googleSignIn = GoogleSignIn();


 Future<bool> login(String email, String password, BuildContext context) async {
  try {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final response = await http.post(
      Uri.parse('http://192.168.1.124:3000/user/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = json.decode(response.body);

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


  Future<bool> signInWithGoogle(BuildContext context) async {
  try {
    print("🔍 Initiating Google sign-in");
    _isLoading = true;
    notifyListeners();

    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      print("❌ Google sign-in aborted by user");
      _error = 'Google sign-in aborted';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    print("✅ Google user obtained: ${googleUser.email}");
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    print("Google authentication token: ${googleAuth.idToken}");

    final response = await http.post(
      Uri.parse('http://192.168.1.133:3000/user/google-login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'token': googleAuth.idToken}),
    );

    print("Response status from Google login: ${response.statusCode}");
    print("Response body from Google login: ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = json.decode(response.body);
      _user = User.fromJson(data['user']);
      print("✅ Google login successful, user id: ${_user?.id}");

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_user?.id != null) {
          print("Fetching profile for Google login, user id: ${_user!.id}");
          Provider.of<ProfileProvider>(context, listen: false).fetchUserProfile(_user!.id!);
        }
        _successMessage = "✅ Google sign-in successful!";
        notifyListeners();
        Navigator.pushReplacementNamed(context, AppRoutes.homePatient);
      });

      return true;
    } else {
      print("❌ Google sign-in failed with status: ${response.statusCode}");
      _error = 'Google sign-in failed';
      notifyListeners();
      return false;
    }
  } catch (e)
   {
    print("❌ Google sign-in error: $e");
    _error = e.toString();
    notifyListeners();
    return false;
  } 
  finally {
    _isLoading = false;
    notifyListeners();
  }}
  void clearError() {
    _error = null;
    notifyListeners();
  }

 void logout() {
  _user = null;
  notifyListeners();
}


}