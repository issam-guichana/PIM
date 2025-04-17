import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pim_project/Controllers/AvatarProvider.dart';
import 'avatar_detail_screen.dart';

class AvatarDefaultScreen extends StatelessWidget {
  const AvatarDefaultScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AvatarProvider()..fetchAvatars(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Sélectionner un Avatar'),
          backgroundColor: const Color(0xFF723D92),
        ),
        body: Consumer<AvatarProvider>(
          builder: (context, controller, child) {
            if (controller.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.errorMessage != null) {
              return Center(
                child: Text(
                  controller.errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }

            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,      // Nombre de colonnes dans la grille
                crossAxisSpacing: 10,   // Espace horizontal entre les cartes
                mainAxisSpacing: 10,    // Espace vertical entre les cartes
                childAspectRatio: 0.8,  // Ajuste le ratio largeur/hauteur des cartes
              ),
              itemCount: controller.avatars.length,
              itemBuilder: (context, index) {
                final avatar = controller.avatars[index];

                return GestureDetector(
                  onTap: () {
                    // Navigation vers l'écran de détail
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AvatarDetailScreen(avatar: avatar),
                      ),
                    );
                  },
                  child: Card(
                    
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FadeInImage.assetNetwork(
                            placeholder: 'assets/loading.png',
                            image: avatar['image'] ?? '',
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                          const SizedBox(height: 10),
                          
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
