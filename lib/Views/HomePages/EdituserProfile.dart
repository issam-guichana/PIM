import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Controllers/ProfileController.dart';

class EditProfileModal extends StatefulWidget {
  final String userId;
  final Function(bool success) onUpdate;

  const EditProfileModal({
    super.key,
    required this.userId,
    required this.onUpdate,
  });

  @override
  State<EditProfileModal> createState() => _EditProfileModalState();
}

class _EditProfileModalState extends State<EditProfileModal> {
  late ProfileController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ProfileController(widget.userId);
    _controller.loadUserData(); // Charger les données de l'utilisateur
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Consumer<ProfileController>(
        builder: (context, controller, child) {
          return Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: controller.isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "Edit Profile",
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                        ),
                        const Divider(),
                        const SizedBox(height: 16),

                        // Username
                        TextField(
                          controller: controller.usernameController,
                          decoration: const InputDecoration(labelText: "Username"),
                        ),
                        const SizedBox(height: 16),

                        // Email
                        TextField(
                          controller: controller.emailController,
                          decoration: const InputDecoration(labelText: "Email"),
                        ),
                        const SizedBox(height: 16),

                        // Date of Birth
                        TextField(
                          controller: controller.dateOfBirthController,
                          decoration: const InputDecoration(labelText: "Date of Birth"),
                        ),
                        const SizedBox(height: 16),

                        // Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
                            ),
                            ElevatedButton(
                              onPressed: controller.isSaving
                                  ? null
                                  : () async {
                                      bool success = await controller.updateUserProfile();
                                      widget.onUpdate(success);
                                      if (success) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text("Profile updated successfully!")),
                                        );
                                        Navigator.pop(context);
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text("Failed to update profile")),
                                        );
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: controller.isSaving
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : const Text("Save", style: TextStyle(fontSize: 16, color: Colors.white)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
          );
        },
      ),
    );
  }
}