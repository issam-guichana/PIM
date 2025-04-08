import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tesst1/Controllers/AuthProvider.dart';
import 'package:tesst1/Controllers/ProfileController.dart';

 // ✅ Import AuthProvider

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final profileProvider = Provider.of<ProfileProvider>(context);
    final userId = authProvider.user?.id; // ✅ Get user ID dynamically

    return Scaffold(
      backgroundColor: const Color(0xFF723D92),
      appBar: AppBar(
        title: const Text('Change Password', style: TextStyle(color: Colors.white)),
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
              // ✅ New Password Field
              _buildPasswordField('New Password', _passwordController, _isPasswordVisible, () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              }),
              const SizedBox(height: 15),

              // ✅ Confirm Password Field
              _buildPasswordField('Confirm Password', _confirmPasswordController, _isConfirmPasswordVisible, () {
                setState(() {
                  _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                });
              }),
              const SizedBox(height: 20),

              // ✅ Error Messages
              if (profileProvider.error != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    profileProvider.error!,
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                  ),
                ),
              if (profileProvider.successMessage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    profileProvider.successMessage!,
                    style: const TextStyle(color: Colors.green, fontSize: 14),
                  ),
                ),
              const SizedBox(height: 20),

              // ✅ Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
  if (_formKey.currentState!.validate()) {
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Passwords do not match!")),
      );
      return;
    }

    if (userId == null || userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Error: User ID not found.")),
      );
      return;
    }

    bool success = await profileProvider.updatePassword(userId, _passwordController.text);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Password changed successfully!")),
      );
      Navigator.pop(context); // ✅ Return to profile screen
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error: ${profileProvider.error}")),
      );
    }
  }
},

                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 249, 215, 255),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: profileProvider.isLoading
                      ? const CircularProgressIndicator(color: Color(0xFF723D92))
                      : const Text('Save', style: TextStyle(color: Color(0xFF723D92), fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ Password Field with Visibility Toggle
  Widget _buildPasswordField(String label, TextEditingController controller, bool isVisible, VoidCallback onToggle) {
    return TextFormField(
      controller: controller,
      obscureText: !isVisible,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        prefixIcon: const Icon(Icons.lock, color: Colors.white70),
        suffixIcon: IconButton(
          icon: Icon(isVisible ? Icons.visibility : Icons.visibility_off, color: Colors.white70),
          onPressed: onToggle,
        ),
      ),
      style: const TextStyle(color: Colors.white),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "⚠ Please enter your password";
        }
        if (value.length < 6) {
          return "⚠ Password must be at least 6 characters";
        }
        return null;
      },
    );
  }
}
