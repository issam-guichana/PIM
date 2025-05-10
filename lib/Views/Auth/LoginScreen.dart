import 'package:flutter/material.dart';
import 'package:pim_project/Controllers/AuthProviders/AuthProvider.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../routes/routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo
                Image.asset(
                  'Assets/SplashScreen/splash_image.png',
                  width: 300,
                  height: 300,
                ),
                const SizedBox(height: 20),
                Card(
                  color: Colors.white,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(color: Colors.white),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Email
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Email",
                              style: TextStyle(fontSize: 16, color: Color(0xFF723D92)),
                            ),
                          ),
                          const SizedBox(height: 5),
                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              hintText: "Email",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: const BorderSide(color: Color.fromARGB(255, 238, 229, 244), width: 1.5),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: const BorderSide(color: Color(0xFF723D92), width: 1.5),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 15),
                          // Password
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Password",
                              style: TextStyle(fontSize: 16, color: Color(0xFF723D92)),
                            ),
                          ),
                          const SizedBox(height: 5),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscureText,
                            decoration: InputDecoration(
                              hintText: "Password",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: const BorderSide(color: Color(0xFF723D92), width: 1.5),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: const BorderSide(color: Color(0xFF723D92), width: 1.5),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility),
                                onPressed: () {
                                  setState(() {
                                    _obscureText = !_obscureText;
                                  });
                                },
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),
                          const Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              "Forgot Password?",
                              style: TextStyle(color: Color(0xFF723D92), fontSize: 14),
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Login Button
                          ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState?.validate() ?? false) {
                                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                                // Afficher un indicateur de chargement
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Logging in...')),
                                );

                                final success = await authProvider.login(
                                  _emailController.text,
                                  _passwordController.text,
                                );

                                if (success) {
                                  print("Login successful. User role: ${authProvider.user?.role}");

                                  // Récupérer l'ID de l'utilisateur
                                  final userId = authProvider.user?.id;

                                  if (userId != null) {
                                    if (authProvider.user!.role == 'user') {
                                      // Naviguer vers la page de profil
                                      Navigator.pushReplacementNamed(context, AppRoutes.HomePatient);
                                    } else if (authProvider.user!.role == 'parent') {
                                      Navigator.pushReplacementNamed(context, AppRoutes.HomeParent);
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Role not recognized')),
                                      );
                                    }
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('User ID is null')),
                                    );
                                  }
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(authProvider.error ?? 'Login failed')),
                                  );
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF723D92),
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Text(
                              "L o g i n",
                              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Or
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(child: Divider(color: Color.fromARGB(185, 181, 178, 178))),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: Text("Or", style: TextStyle(color: Colors.grey)),
                              ),
                              Expanded(child: Divider(color: Color.fromARGB(185, 181, 178, 178))),
                            ],
                          ),
                          const SizedBox(height: 10),
                          // Social Login
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildSocialIcon(FontAwesomeIcons.facebook),
                              const SizedBox(width: 15),
                              _buildSocialIcon(FontAwesomeIcons.google),
                              const SizedBox(width: 15),
                              _buildSocialIcon(FontAwesomeIcons.linkedin),
                            ],
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

  Widget _buildSocialIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF723D92)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: FaIcon(icon, color: const Color(0xFF723D92), size: 24),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}