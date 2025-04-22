import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:version1/Providers/AuthProvider.dart';


class EditProfileDialog extends StatefulWidget {
  const EditProfileDialog({super.key});

  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _dateOfBirthController;
  bool _receiveNotifications = true;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<AuthProvider>(context, listen: false);
    final user = provider.user!;
    _usernameController = TextEditingController(text: user.username);
    _emailController = TextEditingController(text: user.email);
    _dateOfBirthController = TextEditingController(
      text: provider.profile?.dateOfBirth != null
          ? DateFormat('yyyy-MM-dd')
              .format(DateTime.parse(provider.profile!.dateOfBirth!))
          : '',
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<AuthProvider>(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Container(
        // Fond en dégradé pour la bordure extérieure
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF3ED0FA), Color(0xFFB041F0)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Container(
          margin: const EdgeInsets.all(2),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(23),
          ),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Edit Profile",
                    style: TextStyle(
                      fontSize: 20,
                      color: Color(0xFF723D92),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildTextField('First Name', _usernameController, Icons.person),
                  const SizedBox(height: 15),
                  _buildDatePickerField('Date of Birth', _dateOfBirthController, Icons.calendar_today),
                  const SizedBox(height: 15),
                  _buildTextField('Email', _emailController, Icons.email),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Checkbox(
                        value: _receiveNotifications,
                        activeColor: Colors.purple,
                        onChanged: (value) {
                          setState(() {
                            _receiveNotifications = value!;
                          });
                        },
                      ),
                      const Expanded(
                        child: Text(
                          "Receive all notifications and updates",
                          style: TextStyle(color: Colors.black87),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Bouton Save avec le design modifié
                  _buildSaveButton(profileProvider),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Widget pour les champs texte avec un cadre délimité
  Widget _buildTextField(String label, TextEditingController controller, IconData icon) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.black87),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.purple),
        filled: true,
        fillColor: Colors.white,
        prefixIcon: Icon(icon, color: Colors.purple),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.purple),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.purple),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
        ),
      ),
    );
  }

  // Widget pour le champ calendrier avec cadre délimité
  Widget _buildDatePickerField(String label, TextEditingController controller, IconData icon) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.black87),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.purple),
        filled: true,
        fillColor: Colors.white,
        prefixIcon: Icon(icon, color: Colors.purple),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.purple),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.purple),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
        ),
      ),
      readOnly: true,
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: controller.text.isNotEmpty
              ? DateTime.parse(controller.text)
              : DateTime(2000),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );
        if (pickedDate != null) {
          setState(() {
            controller.text = DateFormat('yyyy-MM-dd').format(pickedDate);
          });
        }
      },
    );
  }

  // Bouton Save personnalisé avec design inspiré du bouton SIGN IN
  Widget _buildSaveButton(AuthProvider profileProvider) {
    return GestureDetector(
      onTap: () async {
        if (_formKey.currentState!.validate()) {
          final userId = profileProvider.user?.id;
          if (userId != null) {
            Map<String, dynamic> updatedData = {
              "username": _usernameController.text,
              "email": _emailController.text,
              "dateOfBirth": _dateOfBirthController.text,
            };
            bool success = await profileProvider.updateUserProfile(userId, updatedData);
            if (success) {
  // Mettez à jour manuellement les contrôleurs avec les nouvelles données du profil
  final updatedProfile = profileProvider.profile;
  if (updatedProfile != null) {
    _usernameController.text = updatedProfile.username;
    _emailController.text = updatedProfile.email;
    if (updatedProfile.dateOfBirth != null) {
      _dateOfBirthController.text = DateFormat('yyyy-MM-dd')
          .format(DateTime.parse(updatedProfile.dateOfBirth!));
    }
  }
  Navigator.pop(context);
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("✅ Profile updated successfully!")),
  );
}
else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("❌ Failed to update profile: ${profileProvider.error}")),
              );
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("❌ User ID not found!")),
            );
          }
        }
      },
      child: Container(
        height: 50,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF3ED0FA), Color(0xFFB041F0)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Container(
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Center(
            child: ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFF3ED0FA), Color(0xFFB041F0)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                    "SAVE",
                    style: TextStyle(
                      fontSize: 18,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
