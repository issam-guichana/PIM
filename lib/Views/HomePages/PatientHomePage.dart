import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Controllers/AuthProviders/AuthProvider.dart'; // Importer AuthProvider
import 'CustomBottomNavBar.dart';
import 'EdituserProfile.dart'; // Assurez-vous d'importer EditProfileModal

class HomePagePatient extends StatefulWidget {
  const HomePagePatient({super.key});

  @override
  _HomePagePatientState createState() => _HomePagePatientState();
}

class _HomePagePatientState extends State<HomePagePatient> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userId = authProvider.user?.id; // Récupérer l'ID de l'utilisateur

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
      bottomNavigationBar: CustomBottomBarPatient(
        selectedIndex: _selectedIndex,
        onItemSelected: (index) {
          if (index == 3 && userId != null) {
            // Naviguer vers l'écran d'édition du profil
            showModalBottomSheet(
              context: context,
              builder: (context) => EditProfileModal(
                userId: userId,
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
            _onItemTapped(index); // Appeler la fonction pour d'autres index
          }
        },
      ),
    );
  }

  Widget _buildContactCard(BuildContext context,
      {required String image, required String name}) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFF723D92), width: 2),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(image),
          const SizedBox(width: 8), // Correction ici pour l'espacement
          Column(
            children: [
              Text(
                name,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
              const Icon(Icons.phone_enabled_outlined,
                  size: 25, color: Color(0xFF723D92)),
            ],
          ),
        ],
      ),
    );
  }
}