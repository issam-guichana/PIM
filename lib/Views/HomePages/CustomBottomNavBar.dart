import 'package:flutter/material.dart';


class CustomBottomNavBarPatient extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const CustomBottomNavBarPatient({
    Key? key,
    required this.selectedIndex,
    required this.onItemSelected, required Null Function(int index) onItemTapped,
  }) : super(key: key);

  @override
  _CustomBottomNavBarPatientState createState() => _CustomBottomNavBarPatientState();
}

class _CustomBottomNavBarPatientState extends State<CustomBottomNavBarPatient> {
  final List<IconData> _icons = [
    Icons.home,
    Icons.bar_chart,
    Icons.camera_alt, // Camera in the center
    Icons.calendar_today,
    Icons.person, // Profile icon
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(16),
        height: 60,
        decoration: BoxDecoration(
          color: const Color(0xFF723D92), // Purple background
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black12.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 12,
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
                onTap: () => widget.onItemSelected(2), // Camera index
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.deepPurple.withOpacity(0.4),
                        blurRadius: 15,
                        spreadRadius: 3,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Color(0xFF2F1E56),
                    size: 50,
                  ),
                ),
              ),
            ),

            // Navigation Icons (excluding the camera in the center)
            Positioned(
              bottom: 12,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(_icons.length, (index) {
                  if (index == 2) return const SizedBox(width: 60); // Skip space for the camera

                  return GestureDetector(
                    onTap: () {
                      if (index == 4) {
                        // Navigate to Edit Profile when clicking on profile icon
                        
                      } else {
                        widget.onItemSelected(index);
                      }
                    },
                    child: Icon(
                      _icons[index],
                      size: 40,
                      color: widget.selectedIndex == index ? Colors.white : Colors.white.withOpacity(0.6),
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
}