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
      body:
          isLoading
              ? const Center(
                child: CircularProgressIndicator(color: buttonColor),
              )
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

                    // const Text('Filters', style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
                    // verticalSpace(10),
                    // Row(
                    //   children: [
                    //     Expanded(
                    //       child: DropdownButtonFormField<String>(
                    //         value: selectedCategory,
                    //         decoration: const InputDecoration(labelText: 'Category'),
                    //         items: categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
                    //         onChanged: (value) => setState(() => selectedCategory = value),
                    //       ),
                    //     ),
                    //     horizontalSpace(10),
                    //     Expanded(
                    //       child: FutureBuilder<List<String>>(
                    //         future: DatabaseService.getAllSubCategories(),
                    //         builder: (_, snapshot) {
                    //           return DropdownButtonFormField<String>(
                    //             value: selectedSubCategory,
                    //             decoration: const InputDecoration(labelText: 'SubCategory'),
                    //             items: (snapshot.data ?? [])
                    //                 .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    //                 .toList(),
                    //             onChanged: (value) => setState(() => selectedSubCategory = value),
                    //           );
                    //         },
                    //       ),
                    //     ),
                    //     horizontalSpace(10),
                    //     Expanded(
                    //       child: FutureBuilder<List<String>>(
                    //         future: DatabaseService.getAllProductTypes(),
                    //         builder: (_, snapshot) {
                    //           return DropdownButtonFormField<String>(
                    //             value: selectedProductType,
                    //             decoration: const InputDecoration(labelText: 'Product Type'),
                    //             items: (snapshot.data ?? [])
                    //                 .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                    //                 .toList(),
                    //             onChanged: (value) => setState(() => selectedProductType = value),
                    //           );
                    //         },
                    //       ),
                    //     ),
                    //   ],
                    // ),
                    // verticalSpace(20),


  // // Get Products by Category
  // static Future<List<Map<String, dynamic>>> getProductsByCategory(
  //   String category,
  // ) async {
  //   return await productsCollection
  //       .find(where.eq('category', category))
  //       .toList();
  // }

  // // Get Products by Subcategory
  // static Future<List<Map<String, dynamic>>> getProductsBySubCategory(
  //   String subCategory,
  // ) async {
  //   return await productsCollection
  //       .find(where.eq('subCategory', subCategory))
  //       .toList();
  // }

  // // Get Products by Product Type
  // static Future<List<Map<String, dynamic>>> getProductsByProductType(
  //   String productType,
  // ) async {
  //   return await productsCollection
  //       .find(where.eq('productType', productType))
  //       .toList();
  // }

  // // Get Products by Category and SubCategory
  // static Future<List<Map<String, dynamic>>> getProductsByCategoryAndSubCategory(
  //   String category,
  //   String subCategory,
  // ) async {
  //   return await productsCollection
  //       .find(where.eq('category', category).eq('subCategory', subCategory))
  //       .toList();
  // }

  // // Get Products by Category, SubCategory, and ProductType
  // static Future<List<Map<String, dynamic>>> getProductsByFilters({
  //   required String category,
  //   required String subCategory,
  //   required String productType,
  // }) async {
  //   return await productsCollection
  //       .find(
  //         where
  //             .eq('category', category)
  //             .eq('subCategory', subCategory)
  //             .eq('productType', productType),
  //       )
  //       .toList();
  // }

  // static Future<List<String>> getAllCategories() async {
  //   return await productsCollection.distinct('category') as List<String>;
  // }

  // static Future<List<String>> getAllSubCategories() async {
  //   return await productsCollection.distinct('subCategory') as List<String>;
  // }

  // static Future<List<String>> getAllProductTypes() async {
  //   return await productsCollection.distinct('productType') as List<String>;
  // }

