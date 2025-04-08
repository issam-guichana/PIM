import 'package:flutter/material.dart';
import 'package:tesst1/Views/Auth/LoginScreen.dart';

class SecondIntroScreen extends StatelessWidget {
  const SecondIntroScreen({super.key});

  void _navigateToLoginScreen(BuildContext context) {
    Navigator.of(context).push(_createRoute(const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              flex: 3,
              child: Center(
                child: Image.asset(
                  'assets/splash_image.png',
                  width: screenWidth * 0.8,
                  height: screenHeight * 0.5,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    const Text(
                      'Attention ! Join us and inspire with your words!',
                      style: TextStyle(
                        fontSize: 24,
                        color: Color(0xFF723D92),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 5,
                              backgroundColor: const Color(0xFF723D92).withOpacity(0.4),
                            ),
                            const SizedBox(width: 4),
                            const CircleAvatar(
                              radius: 5,
                              backgroundColor: Color(0xFF723D92),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () => _navigateToLoginScreen(context),
                          child: const CircleAvatar(
                            radius: 24,
                            backgroundColor: Color(0xFF723D92),
                            child: Icon(
                              Icons.arrow_forward,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🎬 Animation Slide Transition
  Route _createRoute(Widget page) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 600),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0); // Départ à droite
        const end = Offset.zero; // Arrivée normale
        const curve = Curves.easeInOut;

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(position: offsetAnimation, child: child);
      },
    );
  }
}
