import 'package:flutter/material.dart';
import 'package:pim_project/Views/IntroPages/SecondIntroPage.dart';

class FirstIntroScreen extends StatelessWidget {
  const FirstIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              // Permet de défiler si le contenu dépasse la hauteur de l'écran
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    // On centre verticalement le contenu
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Center(
                          child: Image.asset(
                            'Assets/SplashScreen/splash_image.png',
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
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Discover the perfect healthcare plan tailored just for you!',
                                style: TextStyle(
                                  fontSize: 24,
                                  color: Color(0xFF723D92),
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const CircleAvatar(
                                        radius: 5,
                                        backgroundColor: Color(0xFF723D92),
                                      ),
                                      const SizedBox(width: 4),
                                      CircleAvatar(
                                        radius: 5,
                                        backgroundColor:
                                            const Color(0xFF723D92)
                                                .withOpacity(0.4),
                                      ),
                                    ],
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        PageRouteBuilder(
                                          pageBuilder: (context, animation,
                                                  secondaryAnimation) =>
                                              const SecondIntroScreen(),
                                          transitionsBuilder: (context,
                                              animation,
                                              secondaryAnimation,
                                              child) {
                                            const begin = Offset(1.0, 0.0);
                                            const end = Offset.zero;
                                            const curve = Curves.easeInOut;
                                            var tween = Tween(
                                                    begin: begin, end: end)
                                                .chain(CurveTween(curve: curve));
                                            var offsetAnimation =
                                                animation.drive(tween);
                                            return SlideTransition(
                                              position: offsetAnimation,
                                              child: child,
                                            );
                                          },
                                        ),
                                      );
                                    },
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
              ),
            );
          },
        ),
      ),
    );
  }
}
