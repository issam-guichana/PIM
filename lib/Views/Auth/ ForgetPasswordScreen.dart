import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../../Controllers/AuthProvider.dart';
import '../../Controllers/ProfileController.dart' show ProfileProvider;
import '../../routes/routes.dart';

class ForgetPasswordDialog extends StatefulWidget {
  const ForgetPasswordDialog({super.key});

  @override
  _ForgetPasswordDialogState createState() => _ForgetPasswordDialogState();
}

class _ForgetPasswordDialogState extends State<ForgetPasswordDialog> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _tempPasswordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isOtpSent = false;
  bool _isOtpVerified = false;
  bool _obscureText = true;

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _tempPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<ProfileProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'Assets/SplashScreen/splash_image.png',
                  width: 150,
                  height: 150,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.error, size: 100, color: Colors.red);
                  },
                ),
                const SizedBox(height: 20),
                if (!_isOtpSent) _buildEmailField(),
                if (_isOtpSent && !_isOtpVerified) _buildOtpField(),
                if (_isOtpVerified) _buildTemporaryPasswordField(),
                const SizedBox(height: 20),
                _buildActionButton(profileProvider, authProvider),
                const SizedBox(height: 10),
                if (profileProvider.error != null && profileProvider.error!.isNotEmpty)
                  Text(
                    profileProvider.error!,
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                  ),
                if (profileProvider.successMessage != null && profileProvider.successMessage!.isNotEmpty)
                  Text(
                    profileProvider.successMessage!,
                    style: const TextStyle(color: Colors.green, fontSize: 14),
                  ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Annuler",
                    style: TextStyle(color: Colors.red),
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
      validator: (value) {
        if (value == null || value.isEmpty) return 'Please enter your email';
        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) return 'Invalid email format';
        return null;
      },
    );
  }

  Widget _buildOtpField() {
    return TextFormField(
      controller: _otpController,
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        labelText: "Enter OTP",
        prefixIcon: Icon(Icons.lock, color: Color(0xFF723D92)),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Please enter the OTP';
        if (value.length != 6) return 'OTP must be 6 digits';
        return null;
      },
    );
  }

  Widget _buildTemporaryPasswordField() {
    return TextFormField(
      controller: _tempPasswordController,
      obscureText: _obscureText,
      decoration: InputDecoration(
        labelText: "Temporary Password",
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
      validator: (value) => value == null || value.isEmpty ? 'Please enter the temporary password' : null,
    );
  }

  Widget _buildActionButton(ProfileProvider profileProvider, AuthProvider authProvider) {
    String buttonText = "Send OTP";
    if (_isOtpSent && !_isOtpVerified) buttonText = "Verify OTP";
    if (_isOtpVerified) buttonText = "Login";

    return ElevatedButton(
      onPressed: profileProvider.isLoading ? null : () => _handleAction(profileProvider, authProvider),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF723D92),
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: profileProvider.isLoading
          ? const CircularProgressIndicator(color: Colors.white)
          : Text(
              buttonText,
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
    );
  }

  Future<void> _handleAction(ProfileProvider profileProvider, AuthProvider authProvider) async {
  if (!_isOtpSent) {
    bool otpSent = await profileProvider.resendOtp(_emailController.text.trim());
    if (otpSent) {
      setState(() {
        _isOtpSent = true;
      });
    }
  } else if (_isOtpSent && !_isOtpVerified) {
    bool otpVerified = await profileProvider.verifyOtp(
      _emailController.text.trim(),
      _otpController.text.trim(),
    );
    if (otpVerified) {
      setState(() {
        _isOtpVerified = true;
      });
    }
  } else if (_isOtpVerified) {
    bool tempPasswordValid = await profileProvider.verifyTemporaryPassword(
      _emailController.text.trim(),
      _tempPasswordController.text.trim(),
    );
    
    if (tempPasswordValid) {
      bool loginSuccess = await authProvider.login(
        _emailController.text.trim(),
        _tempPasswordController.text.trim(),
        context,
      );

      if (loginSuccess) {
        Navigator.pop(context); 
        Navigator.pushReplacementNamed(
          context,
          authProvider.user?.role == 'user' 
              ? AppRoutes.homePatient 
              : AppRoutes.homeParent,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(authProvider.error ?? 'Connexion échouée.'))
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mot de passe temporaire invalide.'))
      );
    }
  }
}


}
