class User {
  final String email;
  final String token;
  final String role; // Ajout du champ pour le rôle

  User({
    required this.email,
    required this.token,
    required this.role, // Ajout du rôle dans le constructeur
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      email: json['email'] ?? '',
      token: json['access_token'] ?? '', // Assurez-vous que le token est correctement nommé
      role: json['role'] ?? '', // Récupération du rôle depuis le JSON
    );
  }
}