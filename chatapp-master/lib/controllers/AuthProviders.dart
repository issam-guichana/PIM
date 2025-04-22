import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class User {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? patientId;
  List<User> relatedUsers; // Made mutable for updates

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.patientId,
    this.relatedUsers = const [],
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      patientId: json['patientId'],
      relatedUsers: (json['relatedUsers'] as List<dynamic>?)
              ?.map((e) => User.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'role': role,
      'patientId': patientId,
      'relatedUsers': relatedUsers.map((e) => e.toJson()).toList(),
    };
  }
}

class AuthProviders with ChangeNotifier {
  User? _user;
  String? _token;
  bool _isLoading = false;
  String _errorMessage = '';

  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  // Login function
  Future<bool> login(
      String email, String password, BuildContext context) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.12:3000/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      print(response.body);
      print(response.statusCode);

      if (response.statusCode == 200) {
        print("000000");
        final data = jsonDecode(response.body);
        _user = User.fromJson(data['user']);
        _token = data['token'];
        print("111111");

        final prefs = await SharedPreferences.getInstance();
        print("2222222");
        await prefs.setString('user', jsonEncode(_user!.toJson()));
        print("33333333");
        await prefs.setString('token', _token!);

        print("hhhhhhhhhhhhhhhhhhhhhhhh");

        // Fetch related users after login
        await fetchRelatedUsers();

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        _errorMessage = jsonDecode(response.body)['message'] ?? 'Login failed';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Network error: $e';
      notifyListeners();
      return false;
    }
  }

  // Register function
  Future<bool> register(String name, String email, String password, String role,
      String? patientId, BuildContext context) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('http://192.168.1,12:3000/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'role': role,
          if (patientId != null) 'patientId': patientId,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        _user = User.fromJson(data['user']);
        _token = data['token'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user', jsonEncode(_user!.toJson()));
        await prefs.setString('token', _token!);

        // Fetch related users after registration
        await fetchRelatedUsers();

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        _errorMessage =
            jsonDecode(response.body)['message'] ?? 'Registration failed';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Network error: $e';
      notifyListeners();
      return false;
    }
  }

  // Fetch related users
  Future<void> fetchRelatedUsers() async {
    if (_user == null || _token == null) return;

    try {
      // Construct the URL using the related-users endpoint
      final url = Uri.parse('http://192.168.1.12:3000/auth/related-users');

      // Prepare the payload with userId
      final payload = {
        'userId': _user!.id, // Pass the user's ID to the request body
      };

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type':
              'application/json', // Ensure Content-Type is set to JSON
        },
        body: jsonEncode(payload), // Send the userId as a JSON payload
      );

      print(response.body);
      print(_token);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        // Update the user object with the related users
        _user = User(
          id: _user!.id,
          name: _user!.name,
          email: _user!.email,
          role: _user!.role,
          patientId: _user!.patientId,
          relatedUsers: data.map((e) => User.fromJson(e)).toList(),
        );

        // Save the updated user object in shared preferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user', jsonEncode(_user!.toJson()));
        notifyListeners();
      } else {
        _errorMessage = 'Failed to fetch related users';
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Failed to fetch related users: $e';
      notifyListeners();
    }
  }

  // Logout function
  void logout() async {
    _user = null;
    _token = null;
    _errorMessage = '';
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
    await prefs.remove('token');
    await prefs.remove('role');
    notifyListeners();
  }
}
