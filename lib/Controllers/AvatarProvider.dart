import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AvatarProvider extends ChangeNotifier {
  List<Map<String, String>> avatars = []; // ✅ Liste des avatars récupérés
  bool isLoading = false;
  String? errorMessage;

  final String backendUrl = "https://6491-196-234-27-227.ngrok-free.app/avatar/default"; // ✅ URL de l'API Backend

  bool _isMounted = true; // ✅ Variable pour suivre si le Provider est encore actif

  @override
  void dispose() {
    _isMounted = false; // ✅ Marquer l'objet comme détruit avant `dispose()`
    super.dispose();
  }

  Future<void> fetchAvatars() async {
  isLoading = true;
  errorMessage = null;
  notifyListeners();

  try {
    print("🔹 Envoi de la requête à $backendUrl");
    final response = await http.get(
      Uri.parse(backendUrl),
      headers: {"Accept": "application/json"},
    );

    print("🔹 Réponse du serveur : ${response.statusCode}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print("✅ Données reçues : $data");

      // ✅ Vérifie que toutes les valeurs sont bien des String
      avatars = List<Map<String, String>>.from(
        (data["avatars"] as List).map((avatar) => {
          "id": avatar["id"].toString(), // ✅ Convertir en String
          "name": avatar["name"].toString(), // ✅ Convertir en String
          "image": avatar["image"]?.toString() ?? "", // ✅ Gérer les valeurs nulles
          "model": avatar["model"]?.toString() ?? "", // ✅ Gérer les valeurs nulles
        })
      );

      print("✅ Avatars formatés : $avatars");
    } else {
      errorMessage = "Erreur : ${response.body}";
      print("❌ Erreur API : $errorMessage");
    }
  } catch (error) {
    errorMessage = "Impossible de contacter le serveur.";
    print("❌ Erreur de connexion : $error");
  } finally {
    isLoading = false;
    notifyListeners();
  }
}

}