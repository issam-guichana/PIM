import 'package:flutter/material.dart';
import 'package:tesst1/HomePages/CustomBottomNavBarParent.dart';
import 'package:tesst1/routes/routes.dart';

class HomePageParent extends StatefulWidget {
  const HomePageParent({super.key});

  @override
  _HomePageParentState createState() => _HomePageParentState();
}

class _HomePageParentState extends State<HomePageParent> {
  int _selectedIndex = 0;

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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Parent Home"),
        backgroundColor: const Color(0xFF9D50BB),
        actions: [
          IconButton(
            icon: const Icon(Icons.message, color: Colors.white, size: 28),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.chat),
          ),
          IconButton(
            icon: const Icon(Icons.call, color: Colors.white, size: 28),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.callHistory),
          ),
        ],
      ),
      body: const Center(child: Text("Parent Home Page")),
      bottomNavigationBar: CustomBottomNavBarParent(
        selectedIndex: _selectedIndex,
        onItemSelected: _onItemTapped,
      ),
    );
  }
}