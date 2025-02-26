class User {
  final String? email;
  final String? id;
  final String? token;
  final String? role;

  User({
    this.id,
    this.email,
    this.token,
    this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'],  // Assuming '_id' is the key in the JSON response.
      email: json['email'],
      token: json['access_token'],  // Make sure the response key is 'access_token'.
      role: json['role'],
    );
  }
}
