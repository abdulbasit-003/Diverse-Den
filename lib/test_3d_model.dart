import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:sample_project/constants.dart';

class TestForYouPage extends StatefulWidget {
  const TestForYouPage({super.key});

  @override
  State<TestForYouPage> createState() => _TestForYouPageState();
}

class _TestForYouPageState extends State<TestForYouPage> {
  final List<String> testModels = [
    "assets/models/new.glb",
    "assets/models/1.glb",
    "assets/models/model1.glb",
    "assets/models/2.glb",
    "assets/models/model1.glb",
    "assets/models/model2.glb",
  ];
  
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fieldBackgroundColor,
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: buttonColor,))
          : PageView.builder(
              scrollDirection: Axis.vertical,
              itemCount: testModels.length,
              itemBuilder: (context, index) {
                String modelPath = testModels[index];

                return Container(
                  color: fieldBackgroundColor,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.6,
                        child: ModelViewer(
                          backgroundColor: Colors.transparent,
                          src: modelPath,
                          alt: "Test 3D Model",
                          ar: true,
                          autoRotate: true,
                          cameraControls: true,
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
