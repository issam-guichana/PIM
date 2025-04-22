import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:version1/Models/EditProfileModel.dart';

import 'dart:convert';

import 'package:version1/Models/LoginModel.dart';
import 'package:version1/Routes/app_routes.dart';

// Définition de l'URL de base de l'API
const String API_BASE_URL = "http://172.16.9.120:3000";

class AuthProvider extends ChangeNotifier {
  User? _user; // Utilisateur connecté (LoginModel)
  EditProfileModel? _profile; // Données détaillées du profil
  bool _isLoading = false;
  String? _error;
  String? _successMessage;

  // Getters
  User? get user => _user;
  EditProfileModel? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get successMessage => _successMessage;
  bool get isAuthenticated => _user != null;

  // ========================
  // Méthodes d'authentification
  // ========================

  Future<bool> login(String email, String password, BuildContext context) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await http.post(
        Uri.parse('$API_BASE_URL/user/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        String token = data['access_token'];

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', token);
        print("✅ Token JWT enregistré avec succès !");

        if (data['user'] == null || data['user']['id'] == null) {
          print("Error: Missing user data in response");
          _error = "Invalid response from server";
          notifyListeners();
          return false;
        }

        _user = User.fromJson(data['user']);
        print("User role: ${_user?.role}");

        // Récupérer le profil utilisateur après login
        await fetchUserProfile(_user!.id);

        _successMessage = "✅ Login successful!";
        notifyListeners();

        // Navigation en fonction du rôle
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_user?.role == 'Patient') {
            Navigator.pushReplacementNamed(context, AppRoutes.HomePatient);
          } else if (_user?.role == 'Responsable') {
            //Navigator.pushReplacementNamed(context, AppRoutes.homeParent);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("❌ Unrecognized role.")),
            );
          }
        });

        return true;
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

  Future<void> checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt_token');

    if (token != null) {
      print("✅ Utilisateur déjà connecté avec le token.");
      // Vous pouvez ici appeler fetchUserProfile si besoin
    } else {
      print("❌ Aucun token trouvé, utilisateur non connecté.");
    }
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    _user = null;
    _profile = null;
    notifyListeners();
  }

  Future<bool> loginWithFaceID() async {
    return false;
  }

  // ========================
  // Méthodes de gestion du profil utilisateur
  // ========================

  Future<void> fetchUserProfile(String userId) async {
  if (userId.isEmpty) {
    print("⚠️ User ID is empty, skipping fetch.");
    return;
  }
  try {
    _isLoading = true;
    _error = null;
    notifyListeners();

    print("🔄 Fetching user profile for ID: $userId");
    final response = await http.get(
      Uri.parse('$API_BASE_URL/user/$userId'),
      headers: {'Content-Type': 'application/json'},
    );

    print("🔎 Profile Fetch Response: ${response.statusCode}");

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print("📝 Profile Data: $data");
      _profile = EditProfileModel.fromJson(data);
      notifyListeners();
    } else {
      print("❌ Error fetching profile: ${response.statusCode}");
      _error = "Échec du chargement du profil";
      notifyListeners();
    }
  } catch (e) {
    print("❌ Exception in fetchUserProfile: $e");
    _error = e.toString();
    notifyListeners();
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}

  Future<bool> updateUserProfile(String userId, Map<String, dynamic> updatedData) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await http.patch(
        Uri.parse('$API_BASE_URL/user/update'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "id": userId,
          ...updatedData,
        }),
      );

      if (response.statusCode == 200) {
        // Mise à jour du profile local avec la réponse
        _profile = EditProfileModel.fromJson(json.decode(response.body));
        // Recharge le profil pour obtenir la version la plus récente
        await fetchUserProfile(userId);
        notifyListeners();
        return true;
      } else {
        _error = "Échec de la mise à jour du profil";
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ========================
  // Méthodes OTP et réinitialisation du mot de passe
  // ========================

  Future<bool> verifyOtp(String email, String otp) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await http.post(
        Uri.parse('$API_BASE_URL/user/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({"identifier": email, "otp": otp}),
      );

      print("🔎 Verify OTP Response: ${response.statusCode} - ${response.body}");

      final responseData = json.decode(response.body);

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          responseData["message"].contains("OTP verified successfully")) {
        _successMessage = "✅ OTP verified successfully! Temporary password sent to your email.";
        notifyListeners();

        // Demande l'envoi du mot de passe temporaire
        await sendTemporaryPassword(email);
        return true;
      } else {
        _error = responseData["message"] ?? "❌ Incorrect OTP.";
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = "❌ Error: ${e.toString()}";
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> sendTemporaryPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$API_BASE_URL/user/forget-password'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({"email": email}),
      );

      print("🔎 Temporary Password Email Response: ${response.statusCode} - ${response.body}");

      if (response.statusCode == 200) {
        _successMessage = "✅ Temporary password sent to your email.";
        notifyListeners();
        return true;
      } else {
        return false;
      }
    } catch (e) {
      _error = "❌ Error: ${e.toString()}";
      notifyListeners();
      return false;
    }
  }

  Future<bool> resendOtp(String email) async {
    try {
      _isLoading = true;
      _error = null;
      _successMessage = null;
      notifyListeners();

      final response = await http.post(
        Uri.parse('$API_BASE_URL/user/resend-otp'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({"email": email}),
      );

      print("🔄 Resend OTP Response: ${response.statusCode} - ${response.body}");

      final responseData = json.decode(response.body);

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          responseData["message"] == "OTP resent successfully") {
        _successMessage = "✅ OTP resent successfully.";
        _error = null;
        notifyListeners();
        return true;
      } else {
        _error = responseData["message"] ?? "❌ Failed to resend OTP.";
        _successMessage = null;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = "❌ Error: ${e.toString()}";
      _successMessage = null;
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updatePassword(String userId, String newPassword) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await http.patch(
        Uri.parse('$API_BASE_URL/user/update-password'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({"id": userId, "password": newPassword}),
      );

      print("🔎 Reset Password Response: ${response.statusCode} - ${response.body}");

      if (response.statusCode == 200) {
        _successMessage = "✅ Password reset successfully.";
        notifyListeners();
        return true;
      } else {
        final responseData = json.decode(response.body);
        _error = responseData["message"] ?? "❌ Failed to reset password.";
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = "❌ Error: ${e.toString()}";
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> forgetPassword(BuildContext context, String email, String newPassword) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await http.post(
        Uri.parse('$API_BASE_URL/user/forget-password'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({"email": email, "newPassword": newPassword}),
      );

      print("🔎 Reset Password Response: ${response.statusCode} - ${response.body}");

      if (response.statusCode == 200) {
        _successMessage = "✅ Password reset successfully.";

        // Auto-login après réinitialisation
        bool loginSuccess = await login(email, newPassword, context);
        if (loginSuccess) {
          return true;
        } else {
          _error = "❌ Password changed, but login failed.";
          notifyListeners();
          return false;
        }
      } else {
        _error = "❌ Failed to reset password.";
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = "❌ Error: ${e.toString()}";
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> verifyTemporaryPassword(String email, String tempPassword) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await http.post(
        Uri.parse('$API_BASE_URL/user/verify-temp-password'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({"email": email, "tempPassword": tempPassword}),
      );

      print("🔎 Temporary Password Verification Response: ${response.statusCode} - ${response.body}");

      final responseData = json.decode(response.body);

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          responseData["success"] == true) {
        _successMessage = "✅ Temporary password is valid.";
        _error = null;
        notifyListeners();
        return true;
      } else {
        _successMessage = null;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = "❌ Error: ${e.toString()}";
      _successMessage = null;
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
