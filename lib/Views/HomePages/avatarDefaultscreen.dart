import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tesst1/Controllers/avatarProvider.dart';

class AvatarDefaultScreen extends StatelessWidget {
  const AvatarDefaultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AvatarProvider()..fetchAvatars(), // ✅ Correction du nom
      child: Scaffold(
        appBar: AppBar(
          title: Text('Sélectionner un Avatar'),
          backgroundColor: Color(0xFF723D92),
        ),
        body: Consumer<AvatarProvider>(
          builder: (context, controller, child) {
            if (controller.isLoading) {
              return Center(child: CircularProgressIndicator());
            }

            if (controller.errorMessage != null) {
              return Center(
                child: Text(
                  controller.errorMessage!,
                  style: TextStyle(color: Colors.red),
                ),
              );
            }

            return GridView.builder(
              padding: EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: controller.avatars.length,
              itemBuilder: (context, index) {
                final avatar = controller.avatars[index]; // ✅ Correction ici !

                return GestureDetector(
                  onTap: () {
                    print("Avatar sélectionné: ${avatar['name']}");
                  },
                  child: Column(
                    children: [
                      FadeInImage.assetNetwork(
                        placeholder: 'assets/loading.png', // ✅ Image temporaire pour éviter les crashs
                        image: avatar['image'] ?? '', // ✅ Vérification pour éviter une erreur null
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                      SizedBox(height: 8),
                      Text(
                        avatar['name'] ?? 'Avatar inconnu', // ✅ Vérifie si name est null
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
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
