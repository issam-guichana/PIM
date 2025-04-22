import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:version1/Providers/AuthProvider.dart';
import 'package:version1/Routes/app_routes.dart';
import 'package:version1/Views/Profile/ChangePasswordScreen.dart';
import 'package:version1/Views/Profile/EditProfile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final profileProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.user != null && authProvider.user!.id.isNotEmpty) {
        profileProvider.fetchUserProfile(authProvider.user!.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      // Fond en dégradé similaire à la page de login
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 219, 170, 255),
              Color.fromARGB(255, 149, 93, 206),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: profileProvider.isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.white))
            : profileProvider.user == null
                ? const Center(
                    child: Text(
                      "❌ Error: Unable to load profile",
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                : SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      child: Column(
                        children: [
                          const SizedBox(height: 40),
                          // Photo de profil avec bouton d'édition
                          Center(
                            child: Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                CircleAvatar(
                                  radius: 50,
                                  backgroundImage: const AssetImage('assets/splash_image.png'),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    // TODO: Implémenter la mise à jour de la photo de profil
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFB041F0),
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 2),
                                    ),
                                    padding: const EdgeInsets.all(6),
                                    child: const Icon(Icons.edit, color: Colors.white, size: 20),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          // Nom d'utilisateur
                          Text(
                            profileProvider.user!.username,
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          const SizedBox(height: 4),
                          // Email dans un conteneur avec bordure dégradée
                          _buildGradientContainer(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                              child: Text(
                                profileProvider.user!.email,
                                style: const TextStyle(fontSize: 14, color: Color(0xFF723D92)),
                              ),
                            ),
                            borderRadius: 12,
                          ),
                          const SizedBox(height: 30),
                          // Carte de menu avec bordure dégradée
                          _buildGradientContainer(
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  _buildMenuItem(Icons.person_outline, "Edit Profile", () {
  showDialog(
    context: context,
    builder: (context) => const EditProfileDialog(),
  );
}),
 _buildMenuItem(Icons.person_outline, "Change Password", () {
  showDialog(
    context: context,
    builder: (context) => const ChangePasswordScreen(),
  );
}),
                                  
                                  const Divider(color: Color(0xFFB041F0), thickness: 1),
                                  _buildMenuItem(Icons.logout, "Logout", () {
                                    _handleLogout(context);
                                  }, isLogout: true),
                                ],
                              ),
                            ),
                            borderRadius: 15,
                          ),
                        ],
                      ),
                    ),
                  ),
      ),
    );
  }

  // Widget helper pour créer un conteneur avec une bordure dégradée
  Widget _buildGradientContainer({required Widget child, double borderRadius = 10}) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3ED0FA), Color(0xFFB041F0)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(borderRadius + 2),
      ),
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: child,
      ),
    );
  }

  // Widget pour les items de menu
  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap, {bool isLogout = false}) {
    final baseColor = isLogout ? Colors.red : const Color(0xFFB041F0);
    return ListTile(
      leading: Icon(icon, color: baseColor),
      title: Text(
        title,
        style: TextStyle(color: baseColor, fontSize: 16),
      ),
      trailing: ShaderMask(
        shaderCallback: (bounds) => const LinearGradient(
          colors: [Color(0xFF3ED0FA), Color(0xFFB041F0)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
        child: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
      ),
      onTap: onTap,
    );
  }

  // Fonction de déconnexion avec confirmation
  void _handleLogout(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Logout", style: TextStyle(color: Colors.black)),
          content: const Text("Are you sure you want to log out?", style: TextStyle(color: Colors.black87)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                authProvider.logout();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: const [
                        Icon(Icons.check_circle, color: Colors.white),
                        SizedBox(width: 10),
                        Text('You have been logged out successfully.'),
                      ],
                    ),
                    duration: const Duration(seconds: 2),
                    backgroundColor: const Color(0xFF723D92),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                );
                Navigator.pushNamedAndRemoveUntil(context, AppRoutes.singin, (route) => false);
              },
              child: const Text("Logout", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
