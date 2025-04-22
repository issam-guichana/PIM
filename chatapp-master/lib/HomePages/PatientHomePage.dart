import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:tesst1/Controllers/AuthProviders.dart';
import 'package:tesst1/HomePages/CustomBottomNavBar.dart';
import 'package:tesst1/routes/routes.dart';
import 'package:provider/provider.dart';

class HomePagePatient extends StatefulWidget {
  const HomePagePatient({super.key});

  @override
  _HomePagePatientState createState() => _HomePagePatientState();
}

class _HomePagePatientState extends State<HomePagePatient> {
  int _selectedIndex = 0;
  User? _user;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final authProvider = Provider.of<AuthProviders>(context, listen: false);
    await authProvider.fetchRelatedUsers();
    setState(() {
      _user = authProvider.user;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 1) {
      Navigator.pushNamed(context, AppRoutes.chat);
    } else if (index == 2) {
      Navigator.pushNamed(context, AppRoutes.callHistory);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Accueil',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: const Color(0xFF9D50BB),
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.message, color: Colors.white, size: 28),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.chat),
          ),
          IconButton(
            icon: const Icon(Icons.call, color: Colors.white, size: 28),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.chat), //callHistory
          ),
        ],
      ),
      body: const Center(child: Text("Patient Home Page")),
      bottomNavigationBar: CustomBottomNavBarPatient(
        selectedIndex: _selectedIndex,
        onItemSelected: _onItemTapped,
      ),
    );
  }
}