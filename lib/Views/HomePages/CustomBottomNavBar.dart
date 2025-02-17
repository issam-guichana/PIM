import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Controllers/ProfileController.dart';
import 'EdituserProfile.dart';

class CustomBottomBarPatient extends StatefulWidget {
  final Function(int) onItemSelected;
  final int selectedIndex;

  const CustomBottomBarPatient({
    super.key,
    required this.onItemSelected,
    this.selectedIndex = 0,
  });

  @override
  State<CustomBottomBarPatient> createState() => _CustomBottomBarState();
}

class _CustomBottomBarState extends State<CustomBottomBarPatient> {
  final List<IconData> _icons = [
    Icons.home,
    Icons.calendar_today,
    Icons.bar_chart,
    Icons.person, // Profile icon is at index 3
  ];

  void _onIconTapped(int index, BuildContext context) {
    if (index == 3) { // Vérifie si l'utilisateur clique sur "profile"
      final profileController = Provider.of<ProfileController>(context, listen: false);

      // Appeler la fonction pour afficher le modal d'édition du profil
      showModalBottomSheet(
        context: context,
        builder: (context) => EditProfileModal(
          userId: profileController.userId,
          onUpdate: (success) {
            if (success) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Profile updated successfully!")),
              );
            }
          },
        ),
      );
    } else {
      widget.onItemSelected(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        height: 70,
        decoration: BoxDecoration(
          color: Colors.white,
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
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // Navigation Icons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(_icons.length, (index) {
                return GestureDetector(
                  onTap: () => _onIconTapped(index, context),
                  child: Icon(
                    _icons[index],
                    size: 28,
                    color: widget.selectedIndex == index
                        ? Colors.deepPurple
                        : Colors.grey.shade400,
                  ),
                );
              }),
            ),

            // Center Camera Button
            Positioned(
              top: -30, // Floating Effect
              child: GestureDetector(
                onTap: () {
                  // Handle Camera Action
                },
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.deepPurple,
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
                    Icons.camera,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}