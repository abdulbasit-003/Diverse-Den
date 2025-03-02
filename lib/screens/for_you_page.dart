import 'package:diverseden/ar_view_page.dart';
import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:diverseden/database_service.dart';

class ForYouPage extends StatefulWidget {
  const ForYouPage({super.key});

  @override
  State<ForYouPage> createState() => _ForYouPageState();
}

class _ForYouPageState extends State<ForYouPage> {
  List<Map<String, dynamic>> products = [];

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  void fetchProducts() async {
    var fetchedProducts = await DatabaseService.getProductsWith3DModels();
    setState(() {
      products = fetchedProducts;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: products.isEmpty
          ? Center(child: CircularProgressIndicator())
          : PageView.builder(
              scrollDirection: Axis.vertical,
              itemCount: products.length,
              itemBuilder: (context, index) {
                String modelPath = products[index]["modelPath"];

                return Container(
                  color: Colors.black,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: ModelViewer(
                          src: modelPath,
                          alt: "3D Product Model",
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
