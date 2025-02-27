import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pim_project/Controllers/AuthProviders/AuthProvider.dart';
import 'package:pim_project/routes/routes.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import '../Models/EditProfileModel.dart';

class ProfileProvider extends ChangeNotifier {
  EditProfileModel? _user;
  bool _isLoading = false;
  String? _error;
  String? _successMessage;
  String? get successMessage => _successMessage;


  EditProfileModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Récupérer les données utilisateur par ID
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
        Uri.parse('http://192.168.1.162:3000/user/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      print("🔎 Profile Fetch Response: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("📝 Profile Data: $data");

        _user = EditProfileModel.fromJson(data);
        notifyListeners();
      } else {
        print("❌ Error fetching profile: ${response.statusCode}");
        _error = "Échec du chargement du profil";
      }
    } catch (e) {
      print("❌ Exception in fetchUserProfile: $e");
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ✅ Mettre à jour le profil utilisateur
  Future<bool> updateUserProfile(String userId, Map<String, dynamic> updatedData) async {
  try {
    _isLoading = true;
    notifyListeners();

    final response = await http.patch( // ✅ Changer PUT -> PATCH
      Uri.parse('http://192.168.1.162:3000/user/update'), // ✅ Enlever l'ID de l'URL
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        "id": userId, // ✅ Ajouter l'ID dans le body
        ...updatedData, // Fusionner les autres champs modifiés
      }),
    );

    print("🔎 Update Response Status: ${response.statusCode}");
    print("📝 Response Body: ${response.body}");

    if (response.statusCode == 200) {
      _user = EditProfileModel.fromJson(json.decode(response.body));
      notifyListeners();
      return true;
    } else {
      _error = "Échec de la mise à jour du profil";
      return false;
    }
  } catch (e) {
    _error = e.toString();
    return false;
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}

Future<bool> verifyOtp(String email, String otp) async {
  try {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final response = await http.post(
      Uri.parse('http://192.168.1.162:3000/user/verify-otp'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({"identifier": email, "otp": otp}),
    );

    print("🔎 Verify OTP Response: ${response.statusCode} - ${response.body}");

    final responseData = json.decode(response.body);

    // ✅ Check if verification is successful
    if ((response.statusCode == 200 || response.statusCode == 201) &&
        responseData["message"] == "OTP verified successfully") {
      _successMessage = "✅ OTP verified successfully!";
      notifyListeners();
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


  /// ✅ Send OTP Function (Forgot Password)
  /// ✅ Send OTP Function (Forgot Password)
Future<bool> sendOtp(String email) async {
  try {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final response = await http.post(
      Uri.parse('http://192.168.1.162:3000/user/send-otp'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({"email": email}),
    );

    print("🔎 Send OTP Response: ${response.statusCode} - ${response.body}");

    final responseData = json.decode(response.body);

    // ✅ Check for status code 201 instead of 200
    if ((response.statusCode == 200 || response.statusCode == 201) &&
        responseData["message"] == "OTP sent successfully") {
      _successMessage = "✅ OTP sent successfully.";
      notifyListeners();
      return true;
    } else {
      _error = responseData["message"] ?? "❌ Failed to send OTP.";
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

  /// ✅ Resend OTP Function
  Future<bool> resendOtp(String email) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await http.post(
        Uri.parse('http://192.168.1.162:3000/user/resend-otp'), // ✅ Correct API route
        headers: {'Content-Type': 'application/json'},
        body: json.encode({"email": email}),
      );

      print("🔄 Resend OTP Response: ${response.statusCode} - ${response.body}");

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData["message"] == "OTP resent successfully") {
        _successMessage = "✅ OTP resent successfully.";
        notifyListeners();
        return true;
      } else {
        _error = responseData["message"] ?? "❌ Failed to resend OTP.";
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
  /// ✅ **Update Password**
  Future<bool> updatePassword(String userId, String newPassword) async {
  try {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final response = await http.patch( // ✅ Change to PATCH
      Uri.parse('http://192.168.1.162:3000/user/update-password'), 
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
      Uri.parse('http://192.168.1.162:3000/user/forget-password'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({"email": email, "newPassword": newPassword}),
    );

    print("🔎 Reset Password Response: ${response.statusCode} - ${response.body}");

    if (response.statusCode == 200) {
      _successMessage = "✅ Password reset successfully.";

      // ✅ **Auto-login after password reset**
      bool loginSuccess = await Provider.of<AuthProvider>(context, listen: false).login(email, newPassword, context);
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

  /// ✅ **Login After Password Reset**
  Future<bool> _loginUser(BuildContext context, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.162:3000/user/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({"email": email, "password": password}),
      );

      print("🔎 Login Response: ${response.statusCode} - ${response.body}");

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        String role = responseData['user']['role'];

        // ✅ **Navigate to the correct home page**
        if (role == 'user') {
          Navigator.pushReplacementNamed(context, AppRoutes.homePatient);
        } else if (role == 'parent') {
          Navigator.pushReplacementNamed(context, AppRoutes.homeParent);
        } else {
          _error = "❌ Unrecognized role.";
          notifyListeners();
          return false;
        }

        _successMessage = "✅ Login successful!";
        notifyListeners();
        return true;
      } else {
        _error = "❌ Login failed.";
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = "❌ Error: ${e.toString()}";
      notifyListeners();
      return false;
    }
  }
}