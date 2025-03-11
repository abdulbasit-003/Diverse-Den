import 'dart:io'; // For checking file existence
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:sample_project/constants.dart';
import 'package:sample_project/database_service.dart';

class ForYouPage extends StatefulWidget {
  const ForYouPage({super.key});

  @override
  State<ForYouPage> createState() => _ForYouPageState();
}

class _ForYouPageState extends State<ForYouPage> {
  List<Map<String, dynamic>> products = [];
  bool isLoading = true; // Loading state

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      var fetchedProducts = await DatabaseService.getProductsWith3DModels();
      if (fetchedProducts.isNotEmpty) {
        fetchedProducts.shuffle(Random()); // Shuffle models randomly
      }
      setState(() {
        products = fetchedProducts;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching products: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fieldBackgroundColor,
      body: isLoading
          ? const Center(child: CircularProgressIndicator()) // Show loader while fetching
          : products.isEmpty
              ? const Center(
                  child: Text(
                    "No 3D models available.",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
                  ),
                )
              : PageView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    String? modelPath = products[index]["modelPath"];

                    return Container(
                      color: fieldBackgroundColor,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: modelPath != null && File(modelPath).existsSync()
                                ? ModelViewer(
                                    backgroundColor: Colors.transparent,
                                    src: modelPath,
                                    alt: "3D Product Model",
                                    ar: true,
                                    autoRotate: true,
                                    cameraControls: true,
                                  )
                                : const Center(
                                    child: Text(
                                      "Model not available or file missing",
                                      style: TextStyle(fontSize: 16, color: Colors.red),
                                    ),
                                  ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
