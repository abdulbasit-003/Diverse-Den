import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

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
