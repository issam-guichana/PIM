import 'package:flutter/material.dart';
import 'package:pim_project/Views/HomePages/CustomBottomNavBarParent.dart';


class HomePageParent extends StatefulWidget {
  const HomePageParent({super.key});

  @override
  _HomePageParentState createState() => _HomePageParentState();
}

class _HomePageParentState extends State<HomePageParent> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    if (index == 2) {
      // 🎯 Ouvrir l'écran de la caméra au lieu de mettre à jour _selectedIndex
      
    } else {
      // Mettre à jour l'index normalement
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const SizedBox(height: 15),
          Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 130, right: 25, left: 25),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF723D92),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  height: 200,
                ),
              ),
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.notifications,
                    size: 50,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 10,
              shadowColor: const Color(0xFF723D92),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'JEUX',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: List.generate(
                                5,
                                (index) => const Icon(Icons.star,
                                    color: Colors.yellow, size: 25),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Spacer(),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBarParent(
        selectedIndex: _selectedIndex,
        onItemSelected: _onItemTapped,
      ),
    );
  }
}
