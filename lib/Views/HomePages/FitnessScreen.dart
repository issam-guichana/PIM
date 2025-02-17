import 'package:flutter/material.dart';
import '../Auth/LoginScreen.dart'; // Import your login page

class Fitnessscreen extends StatelessWidget {
  const Fitnessscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            const Text(
              "My Day",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  _buildCard("Walk", "2232", "steps", Icons.directions_walk),
                  _buildCard("Heart", "98", "bpm", Icons.favorite, gradient: true),
                  _buildCard("Sleep", "7.21", "hours", Icons.nightlight_round),
                  _buildCard("Calories", "553", "kcal", Icons.local_fire_department),
                  _buildCard("Water", "2", "bottles", Icons.local_drink),
                  _buildCard("Gym", "0", "min", Icons.headset),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Go to Login",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(String title, String value, String unit, IconData icon, {bool gradient = false}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: gradient ? Colors.purple : Colors.grey.shade100,
        gradient: gradient
            ? const LinearGradient(
                colors: [Colors.purple, Colors.deepPurple],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: gradient ? Colors.white : Colors.purple, size: 30),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: gradient ? Colors.white : Colors.black,
            ),
          ),
          Text(
            "$title\n$unit",
            style: TextStyle(
              fontSize: 14,
              color: gradient ? Colors.white70 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}
