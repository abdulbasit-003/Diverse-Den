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
            color: Colors.white, 
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: ModelViewer(
                    backgroundColor: Colors.transparent, 
                    src: modelPath, // Load models from assets correctly
                    alt: "Test 3D Model",
                    ar: true, // Enable AR
                    autoRotate: true, // Enable rotation
                    cameraControls: true, // Allow zoom & pan
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

  // void _openARView(BuildContext context, String modelPath) {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => ARViewPage(modelPath: modelPath),
  //     ),
  //   );
  // }
}

// class ARViewPage extends StatelessWidget {
//   final String modelPath;

//   const ARViewPage({super.key, required this.modelPath});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("AR View")),
//       body: Center(
//         child: ModelViewer(
//           backgroundColor: Colors.transparent, // Transparent background for AR
//           src: modelPath, // Load model correctly
//           alt: "3D Product in AR",
//           ar: true, // Enable AR
//           disableZoom: true,
//         ),
//       ),
//     );
//   }
// }
