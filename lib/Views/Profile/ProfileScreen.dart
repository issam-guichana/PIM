// Import for exit()
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tesst1/Controllers/AuthProvider.dart';
import 'package:tesst1/Controllers/ProfileController.dart';
import 'package:tesst1/routes/routes.dart';


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
      final profileProvider = Provider.of<ProfileProvider>(context, listen: false);

      if (authProvider.user != null && authProvider.user!.id.isNotEmpty) {
        profileProvider.fetchUserProfile(authProvider.user!.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<ProfileProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF723D92), // Purple background
      body: profileProvider.isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : profileProvider.user == null
              ? const Center(
                  child: Text("❌ Error: Unable to load profile", style: TextStyle(color: Colors.white)),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 60),

                      // ✅ Profile Picture with Edit Icon
                      Center(
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundImage: const AssetImage('Assets/SplashScreen/splash_image.png'),
                            ),
                            GestureDetector(
                              onTap: () {
                                // TODO: Implement profile picture update
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFF9A68D0),
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

                      // ✅ Username
                      Text(
                        profileProvider.user!.username,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 4),

                      // ✅ Email
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          profileProvider.user!.email,
                          style: const TextStyle(fontSize: 14, color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 30),

                      // ✅ Menu Options
                     Container(
  padding: const EdgeInsets.all(10),
  decoration: BoxDecoration(
    color: Colors.white.withOpacity(0.1), // Match email field's background
    borderRadius: BorderRadius.circular(15), // Rounded corners like the email field
  ),
  child: Column(
    children: [
      _buildMenuItem(Icons.person_outline, "Edit Profile", () {
        Navigator.pushNamed(context, '/editProfile');
      }),
      _buildMenuItem(Icons.lock_outline, "Change Password", () {
        Navigator.pushNamed(context, '/changePassword');
      }),
      const Divider(color: Colors.white24, thickness: 1), // Subtle divider
      _buildMenuItem(Icons.logout, "Logout", () {
        _handleLogout(context);
      }, isLogout: true),
    ],
  ),
),

                    ],
                  ),
                ),
    );
  }

  // ✅ Widget for Menu Items
  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap, {bool isLogout = false}) {
    return ListTile(
      leading: Icon(icon, color: isLogout ? Colors.red : Colors.white),
      title: Text(
        title,
        style: TextStyle(color: isLogout ? Colors.red : Colors.white, fontSize: 16),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
      onTap: onTap,
    );
  }

  // ✅ Logout Function with Confirmation Dialog
 void _handleLogout(BuildContext context) {
  final authProvider = Provider.of<AuthProvider>(context, listen: false);

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Ferme la boîte de dialogue
            },
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Ferme la boîte de dialogue
              authProvider.logout();

              // ✅ Affiche un Snackbar de confirmation de déconnexion
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
    backgroundColor:  Color(0xFF723D92),
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  ),
);


              // ✅ Redirige vers la page de connexion en réinitialisant la navigation
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.login,
                (Route<dynamic> route) => false,
              );
            },
            child: const Text("Logout", style: TextStyle(color: Colors.red)),
          ),
        ],
      );
    },
  );
}

}


