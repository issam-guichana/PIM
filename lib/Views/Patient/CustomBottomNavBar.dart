import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:version1/Views/Avatar/avatar_app.dart';
import 'package:version1/Views/Patient/HomePagePatient.dart';
import 'package:version1/Views/Patient/Jeux/GamesPage.dart';
import 'package:version1/Views/Patient/StatistiquesJeux/StatsScreen.dart';
import 'package:version1/Views/Profile/ProfileScreen.dart';

class CustomBottomNavBarPatient extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const CustomBottomNavBarPatient({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  _CustomBottomNavBarPatientState createState() =>
      _CustomBottomNavBarPatientState();
}

class _CustomBottomNavBarPatientState extends State<CustomBottomNavBarPatient> {
  late int _currentIndex;

  // 7 icônes dans l'ordre voulu
  final List<IconData> _icons = [
    Icons.home,               // 0 Accueil
    Icons.person,             // 1 Avatar
    Icons.camera_alt,         // 2 Caméra
    Icons.health_and_safety,  // 3 Complémentaire
    Icons.settings,           // 4 Profil / Paramètres
    Icons.videogame_asset,    // 5 Jeux
    Icons.bar_chart,          // 6 Statistiques
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.selectedIndex;
  }

  Future<void> _onItemTapped(int index) async {
    setState(() => _currentIndex = index);

    switch (index) {
      case 0:
        // Accueil
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 800),
            pageBuilder: (_, __, ___) => const HomePagePatient(),
            transitionsBuilder: (_, anim, __, child) =>
                FadeTransition(opacity: anim, child: child),
          ),
        );
        break;

      case 1:
        // Avatar (WebView avatar creator)
        {
          final prefs = await SharedPreferences.getInstance();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AvatarHomePage(prefs: prefs),
            ),
          ).then((_) => setState(() {}));
        }
        break;

      case 2:
        // TODO: Caméra
        // Navigator.push(...);
        break;

      case 3:
        // TODO: Navigation complémentaire
        // Navigator.push(...);
        break;

      case 4:
        // Profil / Paramètres
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProfileScreen()),
        ).then((_) => setState(() {}));
        break;

      case 5:
        // Jeux
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const GamesPage()),
        ).then((_) => setState(() {}));
        break;

      case 6:
        // Statistiques
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const StatsScreen()),
        ).then((_) => setState(() {}));
        break;
    }

    // Si vous avez besoin de remonter l'index à un parent :
    widget.onItemSelected(index);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        height: 58,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF3ED0FA),
              Color(0xFFB041F0),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
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
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    isSelected
                        ? Container(
                            margin: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(28),
                            ),
                            child: Center(
                              child: ShaderMask(
                                shaderCallback: (bounds) =>
                                    const LinearGradient(
                                  colors: [
                                    Color(0xFF3ED0FA),
                                    Color(0xFFB041F0),
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ).createShader(
                                  Rect.fromLTWH(
                                      0, 0, bounds.width, bounds.height),
                                ),
                                child: Icon(
                                  _icons[index],
                                  size: 30,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          )
                        : Icon(
                            _icons[index],
                            size: 30,
                            color: Colors.white.withOpacity(0.6),
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
