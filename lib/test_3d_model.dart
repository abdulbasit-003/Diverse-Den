import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

class TestForYouPage extends StatefulWidget {
  const TestForYouPage({super.key});

  @override
  State<TestForYouPage> createState() => _TestForYouPageState();
}

class _TestForYouPageState extends State<TestForYouPage> {
  final List<String> testModels = [
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
            color: Colors.black,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: ModelViewer(
                    src: modelPath,
                    alt: "Test 3D Model",
                    ar: true,
                    autoRotate: true,
                    cameraControls: true,
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    _openARView(context, modelPath);
                  },
                  child: Text("View in AR"),
                ),
                SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  void _openARView(BuildContext context, String modelPath) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ARViewPage(modelPath: modelPath),
      ),
    );
  }
}

class ARViewPage extends StatelessWidget {
  final String modelPath;

  const ARViewPage({super.key, required this.modelPath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("AR View")),
      body: Center(
        child: ModelViewer(
          src: modelPath,
          alt: "3D Product in AR",
          ar: true, // Enables AR mode
          disableZoom: true, // AR View only
        ),
      ),
    );
  }
}
