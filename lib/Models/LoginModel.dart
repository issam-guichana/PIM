class User {
  final String email;
  final String id;
  final String token;
  final String role; // Ajout du champ pour le rôle

  User({required this.id,
    required this.email,
    required this.token,
    required this.role, // Ajout du rôle dans le constructeur
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User( 
      id: json['_id'],
      email: json['email'] ?? '',
      token: json['access_token'] ?? '', // Assurez-vous que le token est correctement nommé
      role: json['role'] ?? '', // Récupération du rôle depuis le JSON
    );
  }
}