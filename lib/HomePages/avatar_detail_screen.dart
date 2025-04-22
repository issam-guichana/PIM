import 'package:flutter/material.dart';

class AvatarDetailScreen extends StatelessWidget {
  final Map<String, dynamic> avatar;

  const AvatarDetailScreen({super.key, required this.avatar});

  @override
  Widget build(BuildContext context) {
    
    final String avatarImage = avatar['image'] ?? '';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF723D92),
      ),
      body: Center(
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min, // S'adapte au contenu
              children: [
                FadeInImage.assetNetwork(
                  placeholder: 'assets/loading.png',
                  image: avatarImage,
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 20),
                
              ],
            ),
          ),
        ),
      ),
    );
  }
}
