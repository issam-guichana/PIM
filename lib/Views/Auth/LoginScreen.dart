import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import ' ForgetPasswordScreen.dart';
import '../../Controllers/AuthProvider.dart';
import '../../routes/routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _obscureText = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/splash_image.png',
                  width: 300,
                  height: 300,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.error, size: 100, color: Colors.red);
                  },
                ),
                const SizedBox(height: 20),
                Card(
                  color: Colors.white,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          _buildEmailField(),
                          const SizedBox(height: 15),
                          _buildPasswordField(),
                          const SizedBox(height: 10),

                          Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  barrierDismissible: false, 
                                  builder: (BuildContext context) {
                                    return const ForgetPasswordDialog();
                                  },
                                );
                              },
                              child: const Text(
                                "Forgot Password?",
                                style: TextStyle(
                                  color: Color(0xFF723D92),
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          ElevatedButton(
                            onPressed: authProvider.isLoading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF723D92),
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: authProvider.isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text(
                                    "L o g i n",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: const InputDecoration(
        labelText: "Email",
        prefixIcon: Icon(Icons.email, color: Color(0xFF723D92)),
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscureText,
      decoration: InputDecoration(
        labelText: "Password",
        prefixIcon: const Icon(Icons.lock, color: Color(0xFF723D92)),
        suffixIcon: IconButton(
          icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility),
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
        ),
      ),
    );
  }

  Future<void> _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      bool success = await authProvider.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        context,
      );

      if (success) {
        Navigator.pushReplacementNamed(
          context,
          authProvider.user?.role == 'user' 
              ? AppRoutes.homePatient 
              : AppRoutes.homeParent,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("❌ Login failed. Please try again.")),
        );
      }
    }
  }
}
