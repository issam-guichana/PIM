import 'package:flutter/material.dart';
import 'package:pim_project/Controllers/AuthProvider.dart';
import 'package:pim_project/Controllers/ProfileController.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authProvider = Provider.of<AuthProvider>(context);
    final profileProvider = Provider.of<ProfileProvider>(context, listen: false);

    if (authProvider.user != null && authProvider.user!.id.isNotEmpty) {
      profileProvider.fetchUserProfile(authProvider.user!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<ProfileProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF723D92),
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

                      // ✅ Menu Options sans Logout
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          children: [
                            _buildMenuItem(Icons.person_outline, "Edit Profile", () {
                              Navigator.pushNamed(context, '/editProfile');
                            }),
                            _buildMenuItem(Icons.lock_outline, "Change Password", () {
                              Navigator.pushNamed(context, '/changePassword');
                            }),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
      onTap: onTap,
    );
  }
}
