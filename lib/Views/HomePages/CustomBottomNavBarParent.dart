import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:tesst1/Views/HomePages/camera.dart';
import 'package:tesst1/Views/Profile/ProfileScreen.dart';


class CustomBottomNavBarParent extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const CustomBottomNavBarParent({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  _CustomBottomNavBarParentState createState() => _CustomBottomNavBarParentState();
}

class _CustomBottomNavBarParentState extends State<CustomBottomNavBarParent> {
  final List<IconData> _icons = [
    Icons.home,
    Icons.bar_chart,
    Icons.camera_alt, // Floating Camera in the center
    Icons.calendar_today,
    Icons.person,
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        height: 75,
        decoration: BoxDecoration(
          color: const Color(0xFF723D92),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            // Floating Camera Button in Center
            Positioned(
              top: -35,
              child: GestureDetector(
                onTap: () async {
  try {
    final cameras = await availableCameras(); // Obtenir les caméras disponibles
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ObjectDetectionScreen(cameras)),
    );
  } catch (e) {
    print("Erreur lors de l'accès à la caméra : $e");
  }
},

                child: Container(
                  width: 65,
                  height: 65,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.deepPurple.withOpacity(0.3),
                        blurRadius: 12,
                        spreadRadius: 2,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Color(0xFF2F1E56),
                    size: 40,
                  ),
                ),
              ),
            ),

            // Navigation Icons (excluding the camera in the center)
            Positioned(
              bottom: 10,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(_icons.length, (index) {
                  if (index == 2) return const SizedBox(width: 80); // Skip space for floating camera

                  return GestureDetector(
                    onTap: () {
                      if (index == 4) {
                        // 📌 Navigate to ProfileScreen on clicking Profile
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ProfileScreen()),
                        );
                      } else {
                        // ✅ Update selected index
                        widget.onItemSelected(index);
                      }
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _icons[index],
                          size: 34,
                          color: widget.selectedIndex == index
                              ? Colors.white
                              : Colors.white.withOpacity(0.6),
                        ),
                        const SizedBox(height: 4), // Space between icon and text
                        Text(
                          _getLabel(index),
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                            color: widget.selectedIndex == index
                                ? Colors.white
                                : Colors.white.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// **Helper Function for Labels**
  String _getLabel(int index) {
    switch (index) {
      case 0:
        return "Home";
      case 1:
        return "Stats";
      case 3:
        return "Calendar";
      case 4:
        return "Profile";
      default:
        return "";
    }
  }
}
