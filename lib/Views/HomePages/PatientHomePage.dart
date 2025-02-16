import 'package:flutter/material.dart';
import 'package:pim_project/Views/AssistantVocalScreens/SpeechInteractionPage.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const SizedBox(
            height: 15,
          ),
          Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 130, right: 25, left: 25),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF723D92),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  height: 200,
                ),
              ),
              Center(
                child: Image.asset("Assets/HomePatientAssets/avatar.png"),
              ),
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.notifications,
                    size: 50,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildContactCard(
                context,
                image: "Assets/HomePatientAssets/doctor.png",
                name: 'Dr. Hamza Tariq',
              ),
              _buildContactCard(
                context,
                image: "Assets/HomePatientAssets/fils.png",
                name: 'Ma fille Monjia',
              ),
            ],
          ),
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 10,
              shadowColor: const Color(0xFF723D92),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: 120,
                          height: 150,
                          child:
                              Image.asset("Assets/HomePatientAssets/brain.png"),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'JEUX',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: List.generate(
                                5,
                                (index) => const Icon(Icons.star,
                                    color: Colors.yellow, size: 25),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.camera_alt,
                      size: 40, color: Color(0xFF723D92)),
                ),
                FloatingActionButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SpeechInteractionPage()),
                    );
                  },
                  backgroundColor: const Color(0xFF723D92),
                  child: const Icon(Icons.mic,color: Colors.white, size: 30),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard(BuildContext context,
      {required String image, required String name}) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFF723D92), width: 2),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(image),
          const SizedBox(height: 8),
          Column(
            children: [
              Text(
                name,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
              const Icon(Icons.phone_enabled_outlined,
                  size: 25, color: Color(0xFF723D92)),
            ],
          ),
        ],
      ),
    );
  }
}
