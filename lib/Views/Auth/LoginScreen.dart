import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pim_project/Controllers/AuthProvider.dart';
import 'package:pim_project/routes/routes.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Image.asset(
                'Assets/SplashScreen/splash_image.png',
                height: 200,
                errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 100),
              ),
              const SizedBox(height: 20),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: "Email",
                        prefixIcon: Icon(Icons.email),
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Enter email'
                          : (!value.contains('@') ? 'Invalid email' : null),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscure,
                      decoration: InputDecoration(
                        labelText: "Password",
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscure ? Icons.visibility : Icons.visibility_off,
                          ),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Enter password'
                          : null,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: auth.isLoading ? null : _handleLogin,
                      child: auth.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("Login"),
                    ),
                  ],
                ),
              ),
              if (auth.error != null) ...[
                const SizedBox(height: 12),
                Text(auth.error!, style: const TextStyle(color: Colors.red)),
              ],
              const SizedBox(height: 24),
              const Divider(thickness: 1),
              const SizedBox(height: 8),
              const Text("Or continue with"),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: auth.isLoading ? null : _handleGoogleLogin,
                icon: const FaIcon(FontAwesomeIcons.google, color: Colors.white),
                label: const Text("Sign in with Google"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final success = await auth.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        context,
      );
      if (success) {
        Navigator.pushReplacementNamed(context, AppRoutes.homePatient);
      }
    }
  }

  Future<void> _handleGoogleLogin() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final success = await auth.signInWithGoogle(context);
    if (success) {
      // Laisse la navigation au niveau du bouton dans AuthProvider
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Échec de la connexion Google")),
      );
    }
  }
}
