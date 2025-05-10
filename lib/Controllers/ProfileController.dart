import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ProfileController extends ChangeNotifier {
  final String apiUrl = "http://10.0.2.2:3000/user"; // URL de base
  String userId; // ID de l'utilisateur connecté

  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController dateOfBirthController = TextEditingController();

  bool isLoading = true;
  bool isSaving = false;

  ProfileController(this.userId);

  // Charger les informations utilisateur depuis l'API
  Future<void> loadUserData() async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(Uri.parse('$apiUrl/$userId'));
      if (response.statusCode == 200) {
        final userData = json.decode(response.body);
        usernameController.text = userData['username'];
        emailController.text = userData['email'];
        dateOfBirthController.text = userData['dateOfBirth'];
      } else {
        throw Exception('Failed to load user data');
      }
    } catch (e) {
      print("Erreur de chargement des données utilisateur: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Fonction pour mettre à jour l'utilisateur
  Future<bool> updateUserProfile() async {
    isSaving = true;
    notifyListeners();

    final updatedData = {
      "username": usernameController.text.trim(),
      "email": emailController.text.trim(),
      "dateOfBirth": dateOfBirthController.text.trim(),
    };

    try {
      final response = await http.patch(
        Uri.parse('$apiUrl/update'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'id': userId, ...updatedData}),
      );

      return response.statusCode == 200;
    } catch (e) {
      print("Erreur de mise à jour du profil: $e");
      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }
}