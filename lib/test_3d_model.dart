import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

class TestForYouPage extends StatefulWidget {
  const TestForYouPage({super.key});

  @override
  State<TestForYouPage> createState() => _TestForYouPageState();
}

class _TestForYouPageState extends State<TestForYouPage> {
  final List<String> testModels = [
    "assets/models/1.glb",
    "assets/models/model1.glb",
    "assets/models/2.glb",
    "assets/models/model1.glb",
    "assets/models/model2.glb",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        scrollDirection: Axis.vertical,
        itemCount: testModels.length,
        itemBuilder: (context, index) {
          String modelPath = testModels[index];

          return Container(
            color: Colors.white, 
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: ModelViewer(
                    backgroundColor: Colors.transparent, 
                    src: modelPath, 
                    alt: "Test 3D Model",
                    ar: true, // Enable AR
                    autoRotate: true, // For rotation
                    cameraControls: true, // For zoom & pan
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          );
        },
      ),
    );
  }
}