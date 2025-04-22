import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:version1/Providers/AuthProvider.dart';


class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  _ChangePasswordPopupState createState() => _ChangePasswordPopupState();
}

class _ChangePasswordPopupState extends State<ChangePasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Contrôleur pour l'email
  final TextEditingController _emailController = TextEditingController();
  // Contrôleurs pour saisir les 6 chiffres de l'OTP
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  // Contrôleurs pour le nouveau mot de passe et sa confirmation
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  // Pour gérer la visibilité des champs de mot de passe
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  // Étapes d'avancement :
  // 1 : Saisie de l'email
  // 2 : Saisie et vérification de l'OTP
  // 3 : Saisie et confirmation du nouveau mot de passe
  int _currentStep = 1;

  // Pour gérer le cooldown du bouton de renvoi OTP
  int _resendCooldown = 0;
  Timer? _resendTimer;

  @override
  void dispose() {
    _emailController.dispose();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _resendTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF3ED0FA), Color(0xFFB041F0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Container(
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // En-tête : titre et bouton de fermeture
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _getTitle(),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF8D48AA),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.grey),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Instruction selon l'étape
                    Text(
                      _getInstruction(),
                      style: const TextStyle(color: Colors.black),
                    ),
                    const SizedBox(height: 16),
                    // Affichage du contenu en fonction de l'étape
                    if (_currentStep == 1)
                      _buildEmailField()
                    else if (_currentStep == 2)
                      _buildOtpBoxes()
                    else if (_currentStep == 3)
                      _buildNewPasswordFields(),
                    const SizedBox(height: 20),
                    _buildActionButton(authProvider),
                    const SizedBox(height: 12),
                    // Affichage des messages d'erreur uniquement
                    if (authProvider.error != null && authProvider.error!.isNotEmpty)
                      Text(
                        authProvider.error!,
                        style: const TextStyle(color: Colors.red, fontSize: 14),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getTitle() {
    if (_currentStep == 1) return "Enter Email";
    if (_currentStep == 2) return "OTP Verification";
    if (_currentStep == 3) return "Reset Password";
    return "";
  }

  String _getInstruction() {
    if (_currentStep == 1) return "Enter your email to receive an OTP";
    if (_currentStep == 2) return "Enter the 6-digit OTP code";
    if (_currentStep == 3) return "Enter and confirm your new password";
    return "";
  }

  // Champ de saisie pour l'email
  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      style: const TextStyle(color: Colors.black),
      decoration: const InputDecoration(
        labelText: "Email",
        labelStyle: TextStyle(color: Colors.grey),
        prefixIcon: Icon(Icons.email, color: Colors.grey),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.black),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Please enter your email';
        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value))
          return 'Invalid email format';
        return null;
      },
    );
  }

  // Six cases pour saisir l'OTP
  Widget _buildOtpBoxes() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(6, (index) {
        return SizedBox(
          width: 40,
          child: TextFormField(
            controller: _otpControllers[index],
            keyboardType: TextInputType.number,
            maxLength: 1,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18),
            decoration: const InputDecoration(
              counterText: "",
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
              ),
            ),
            onChanged: (value) {
              if (value.length == 1) {
                FocusScope.of(context).nextFocus();
              }
            },
            validator: (value) {
              if (value == null || value.isEmpty) return '';
              return null;
            },
          ),
        );
      }),
    );
  }

  // Champs pour saisir et confirmer le nouveau mot de passe
  Widget _buildNewPasswordFields() {
    return Column(
      children: [
        _buildPasswordField(
          "New Password",
          _newPasswordController,
          _obscureNewPassword,
          () {
            setState(() {
              _obscureNewPassword = !_obscureNewPassword;
            });
          },
        ),
        const SizedBox(height: 15),
        _buildPasswordField(
          "Confirm Password",
          _confirmPasswordController,
          _obscureConfirmPassword,
          () {
            setState(() {
              _obscureConfirmPassword = !_obscureConfirmPassword;
            });
          },
        ),
      ],
    );
  }

  Widget _buildPasswordField(String label, TextEditingController controller, bool isObscure, VoidCallback onToggle) {
    return TextFormField(
      controller: controller,
      obscureText: isObscure,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        prefixIcon: const Icon(Icons.lock, color: Colors.grey),
        suffixIcon: IconButton(
          icon: Icon(isObscure ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
          onPressed: onToggle,
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.black),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty)
          return "Please enter your password";
        if (value.length < 6)
          return "Password must be at least 6 characters";
        return null;
      },
    );
  }

  Widget _buildActionButton(AuthProvider authProvider) {
    String buttonText = "Send OTP";
    double width = 200;
    double height = 50;
    if (_currentStep == 2) {
      buttonText = _resendCooldown > 0 ? "Wait $_resendCooldown s" : "Verify OTP";
    }
    if (_currentStep == 3) {
      buttonText = "Reset Password";
      width = 200;
      height = 50;
    }

    return GestureDetector(
      onTap: authProvider.isLoading || (_currentStep == 2 && _resendCooldown > 0)
          ? null
          : () => _handleAction(authProvider),
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF3ED0FA), Color(0xFFB041F0)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          margin: const EdgeInsets.all(1),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Center(
            child: authProvider.isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFF3ED0FA), Color(0xFFB041F0)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          buttonText,
                          style: const TextStyle(
                            fontSize: 14,
                            letterSpacing: 1,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 14),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleAction(AuthProvider authProvider) async {
    if (_currentStep == 1) {
      // Étape 1: Envoi de l'OTP après saisie de l'email
      if (_formKey.currentState!.validate()) {
        bool sent = await authProvider.resendOtp(_emailController.text.trim());
        if (sent) {
          setState(() {
            _currentStep = 2;
          });
        } else if (authProvider.error != null && authProvider.error!.contains("60 seconds")) {
          setState(() {
            _resendCooldown = 60;
          });
          _resendTimer?.cancel();
          _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
            setState(() {
              if (_resendCooldown > 0) {
                _resendCooldown--;
              } else {
                timer.cancel();
              }
            });
          });
        }
      }
    } else if (_currentStep == 2) {
      // Étape 2: Vérification de l'OTP
      String otpCode = _otpControllers.map((controller) => controller.text).join();
      if (otpCode.length != 6) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Enter complete 6-digit OTP")));
        return;
      }
      bool verified = await authProvider.verifyOtp(
        _emailController.text.trim(),
        otpCode.trim(),
      );
      if (verified) {
        setState(() {
          _currentStep = 3;
        });
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Invalid or expired OTP.")));
      }
    } else if (_currentStep == 3) {
      // Étape 3: Vérification des champs du nouveau mot de passe et appel de la réinitialisation
      if (_formKey.currentState!.validate()) {
        if (_newPasswordController.text != _confirmPasswordController.text) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text("Passwords do not match!")));
          return;
        }
        bool success = await authProvider.updatePassword(
          _emailController.text.trim(),
          _newPasswordController.text.trim(),
        );
        if (success) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text("Password reset successfully!")));
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text("Error: ${authProvider.error}")));
        }
      }
    }
  }
}
