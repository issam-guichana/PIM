import 'package:flutter/material.dart';
import 'package:pim_project/Views/HomePages/PatientHomePage.dart';
import 'package:pim_project/Views/HomePages/health_screen.dart';
import 'package:pim_project/Views/Profile/ProfileScreen.dart';

class CustomBottomNavBarPatient extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const CustomBottomNavBarPatient({
    Key? key,
    required this.selectedIndex,
    required this.onItemSelected,
  }) : super(key: key);

  @override
  _CustomBottomNavBarPatientState createState() =>
      _CustomBottomNavBarPatientState();
} 

class _CustomBottomNavBarPatientState extends State<CustomBottomNavBarPatient> {
  int _currentIndex = 0;

  final List<IconData> _icons = [
    Icons.home,          // Accueil
    Icons.person,        // Avatar (bouton profil)
    Icons.camera_alt,    // Caméra
    Icons.health_and_safety,
    Icons.settings,      // Paramètres
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.selectedIndex;
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    if (index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const HomePagePatient(),
        ),
      ).then((_) {
        setState(() {
          _currentIndex = 0;
        });
      });
    } else if (index == 1) {
      // Ajoutez ici le comportement pour l'avatar ou profil si nécessaire
    } else if (index == 2) {
      // Intégrer la fonctionnalité de la caméra ici
      
    } else if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const HealthScreen(),
        ),
      ).then((_) {
        setState(() {
          _currentIndex = 3;
        });
      });
    } else if (index == 4) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ProfileScreen(),
        ),
      ).then((_) {
        setState(() {
          _currentIndex = 4;
        });
      });
    } else {
      widget.onItemSelected(index);
    }
  }

  

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        height: 58,
        decoration: BoxDecoration(
          color: const Color(0xFF723D92),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black12.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(_icons.length, (index) {
            final isSelected = _currentIndex == index;
            return GestureDetector(
              onTap: () => _onItemTapped(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                transform: Matrix4.translationValues(
                  0,
                  isSelected ? -8 : 0,
                  0,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _icons[index],
                      size: 30,
                      color: isSelected
                          ? Colors.white
                          : Colors.white.withOpacity(0.6),
                    ),
                    if (isSelected)
                      Container(
                        margin: const EdgeInsets.only(top: 2),
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.6),
                              blurRadius: 6,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
