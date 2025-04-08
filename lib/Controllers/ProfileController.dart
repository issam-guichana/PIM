import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:tesst1/Controllers/AuthProvider.dart';
import 'package:tesst1/routes/routes.dart';
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
        Uri.parse('http://10.0.2.2:3000/user/$userId'),
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
      Uri.parse('http://172.20.10.6:3000/user/update'), // ✅ Enlever l'ID de l'URL
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
      Uri.parse('http://172.20.10.6:3000/user/verify-otp'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({"identifier": email, "otp": otp}),
    );

    print("🔎 Verify OTP Response: ${response.statusCode} - ${response.body}");

    final responseData = json.decode(response.body);

    if ((response.statusCode == 200 || response.statusCode == 201) &&
        responseData["message"].contains("OTP verified successfully")) {
      _successMessage = "✅ OTP verified successfully! Temporary password sent to your email.";
      notifyListeners();

      // ✅ Nouvelle étape : Demander explicitement l'envoi du mot de passe temporaire
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

/// ✅ **Nouvelle méthode pour déclencher l'envoi du mot de passe temporaire**
Future<bool> sendTemporaryPassword(String email) async {
  try {
    final response = await http.post(
      Uri.parse('http://172.20.10.6:3000/user/forget-password'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({"email": email}),
    );

    print("🔎 Temporary Password Email Response: ${response.statusCode} - ${response.body}");

    if (response.statusCode == 200) {
      _successMessage = "✅ Temporary password sent to your email.";
      notifyListeners();
      return true;
    } else {
      _error = "❌ Failed to send temporary password.";
      notifyListeners();
      return false;
    }
  } catch (e) {
    _error = "❌ Error: ${e.toString()}";
    notifyListeners();
    return false;
  }
}

  /// ✅ Resend OTP Function
  /// ✅ Resend OTP Function
Future<bool> resendOtp(String email) async {
    try {
        _isLoading = true;
        _error = null;
        _successMessage = null; // Clear previous success messages
        notifyListeners();

        final response = await http.post(
            Uri.parse('http://172.20.10.6:3000/user/resend-otp'), // ✅ Correct API route
            headers: {'Content-Type': 'application/json'},
            body: json.encode({"email": email}),
        );

        print("🔄 Resend OTP Response: ${response.statusCode} - ${response.body}");

        final responseData = json.decode(response.body);

        /// ✅ Accept both 200 and 201 as success status codes
        if ((response.statusCode == 200 || response.statusCode == 201) &&
            responseData["message"] == "OTP resent successfully") {
                
            _successMessage = "✅ OTP resent successfully.";
            _error = null; // Clear any previous error messages
            notifyListeners();
            return true;
        } else {
            _error = responseData["message"] ?? "❌ Failed to resend OTP.";
            _successMessage = null; // Clear any previous success messages
            notifyListeners();
            return false;
        }
    } catch (e) {
        _error = "❌ Error: ${e.toString()}";
        _successMessage = null; // Clear any previous success messages
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
      Uri.parse('http://172.20.10.6:3000/user/update-password'), // ✅ Ensure correct API endpoint
      headers: {'Content-Type': 'application/json'},
      body: json.encode({"id": userId, "password": newPassword}), // ✅ Send ID instead of email
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
      Uri.parse('http://172.20.10.6:3000/user/forget-password'),
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
        Uri.parse('http:/10.0.2.2/:3000/user/login'),
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
  
  /// ✅ **Vérification du mot de passe temporaire**

Future<bool> verifyTemporaryPassword(String email, String tempPassword) async {
  try {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final response = await http.post(
      Uri.parse('http://172.20.10.6:3000/user/verify-temp-password'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({"email": email, "tempPassword": tempPassword}),
    );

    print("🔎 Temporary Password Verification Response: ${response.statusCode} - ${response.body}");

    final responseData = json.decode(response.body);

    if ((response.statusCode == 200 || response.statusCode == 201) &&
        responseData["success"] == true) {
      _successMessage = "✅ Temporary password is valid.";
      _error = null; // Clear any previous errors
      notifyListeners();
      return true;
    } else {
      _successMessage = null; // Clear success message
      notifyListeners();
      return false;
    }
  } catch (e) {
    _error = "❌ Error: ${e.toString()}";
    _successMessage = null; // Clear success message
    notifyListeners();
    return false;
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}


}
