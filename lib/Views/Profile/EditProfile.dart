import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tesst1/Controllers/ProfileController.dart';


class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _dateOfBirthController;
  bool _receiveNotifications = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
      if (profileProvider.user == null) {
        profileProvider.fetchUserProfile(profileProvider.user?.id ?? "");
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    if (profileProvider.user != null) {
      _usernameController = TextEditingController(text: profileProvider.user!.username);
      _emailController = TextEditingController(text: profileProvider.user!.email);
      _dateOfBirthController = TextEditingController(
        text: profileProvider.user!.dateOfBirth != null
            ? DateFormat('yyyy-MM-dd').format(DateTime.parse(profileProvider.user!.dateOfBirth!))
            : '',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<ProfileProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF723D92),
      appBar: AppBar(
        title: const Text('Edit Profile', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField('First Name', _usernameController, Icons.person),
              const SizedBox(height: 15),

              // ✅ Remplacement du champ Last Name par un champ calendrier 📅
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
                      "All information notifications, promos, and activity updates will be sent via this email",
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ✅ Bouton Save stylisé 🎨
              SizedBox(
  width: double.infinity,
  child: ElevatedButton(
    onPressed: () async {
      if (_formKey.currentState?.validate() ?? false) {
        final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
        final userId = profileProvider.user?.id; // ✅ Get logged-in user ID

        if (userId != null) {
          Map<String, dynamic> updatedData = {
            "username": _usernameController.text,
            "email": _emailController.text,
            "dateOfBirth": _dateOfBirthController.text,
          };

          bool success = await profileProvider.updateUserProfile(userId, updatedData);

          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("✅ Profile updated successfully!"))
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("❌ Failed to update profile: ${profileProvider.error}"))
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("❌ User ID not found!"))
          );
        }
      }
    },
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color.fromARGB(255, 249, 215, 255),
      padding: const EdgeInsets.symmetric(vertical: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    child: const Text(
      'Save',
      style: TextStyle(color: Color(0xFF723D92), fontSize: 18),
    ),
  ),
),

            ],
          ),
        ),
      ),
    );
  }

  // ✅ Widget pour les champs texte
  Widget _buildTextField(String label, TextEditingController controller, IconData icon) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        prefixIcon: Icon(icon, color: Colors.white70),
      ),
      style: const TextStyle(color: Colors.white),
    );
  }

  // ✅ Widget pour le champ calendrier 📅
  Widget _buildDatePickerField(String label, TextEditingController controller, IconData icon) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        prefixIcon: Icon(icon, color: Colors.white70),
      ),
      style: const TextStyle(color: Colors.white),
      readOnly: true,
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: _dateOfBirthController.text.isNotEmpty
              ? DateTime.parse(_dateOfBirthController.text)
              : DateTime(2000),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );
        setState(() {
          _dateOfBirthController.text = DateFormat('yyyy-MM-dd').format(pickedDate!);
        });
            },
    );
  }
}
