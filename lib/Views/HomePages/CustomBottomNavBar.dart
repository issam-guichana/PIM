import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pim_project/Controllers/AuthProvider.dart';
import 'package:pim_project/Views/HomePages/PatientHomePage.dart';
import 'package:pim_project/Views/HomePages/fit_screen.dart';
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
  _CustomBottomNavBarPatientState createState() => _CustomBottomNavBarPatientState();
}

class _CustomBottomNavBarPatientState extends State<CustomBottomNavBarPatient> {
  int _currentIndex = 0;

  final List<IconData> _icons = [
    Icons.home,
    Icons.person,
    Icons.camera_alt,
    Icons.health_and_safety,
    Icons.settings,
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.selectedIndex;
  }

  Future<void> _onItemTapped(int index) async {
    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const HomePagePatient()),
        ).then((_) => setState(() => _currentIndex = 0));
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProfileScreen()),
        ).then((_) => setState(() => _currentIndex = 1));
        break;
      case 3:
        final authProvider = Provider.of<AuthProvider>(context, listen: false);

        if (authProvider.fitData.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Chargement des données Google Fit...')),
          );
        }

        await Future.delayed(const Duration(milliseconds: 500));

        final fitData = authProvider.fitData;

        final hasValidFitData = fitData.isNotEmpty &&
            fitData['bucket'] != null &&
            fitData['bucket'] is List &&
            (fitData['bucket'] as List).isNotEmpty;
if (hasValidFitData) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => FitScreen(
        fitData: fitData,  // Ensure fitData is valid and defined before passing it
        accessToken: '',   // You can add the actual token here if needed
      ),
    ),
  ).then((_) {
    setState(() {
      // Updating the current index after returning from FitScreen
      _currentIndex = 3;  
    });
  });
}
 else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('🚫 Aucune donnée Google Fit disponible pour aujourd’hui.'),
              duration: Duration(seconds: 3),
            ),
          );
        }
        break;
      case 4:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProfileScreen()),
        ).then((_) => setState(() => _currentIndex = 4));
        break;
      default:
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
                      color: isSelected ? Colors.white : Colors.white.withOpacity(0.6),
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
