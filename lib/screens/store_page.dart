import 'package:flutter/material.dart';
import 'package:sample_project/screens/cart_page.dart';
import 'package:sample_project/screens/product_details_page.dart';
import '../database_service.dart';
import '../constants.dart';
import '../models/product.dart';
import 'package:sample_project/screens/category_view_screen.dart';

class StorePage extends StatefulWidget {
  const StorePage({super.key});

  @override
  State<StorePage> createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {
  String? selectedCategory;
  String? selectedSubCategory;
  String? selectedProductType;
  int cartItemCount = 0;

  List<Product> allProducts = [];
  bool isLoading = true;

  final List<String> categories = [
    'Clothing',
    'Shoes',
    'Furniture',
    'DecorationPieces',
  ];

  // Fetch Cart Items Count
  Future<void> fetchCartItemCount() async {
    final cartItems = await DatabaseService.getCartItemsForCurrentUser();
    setState(() {
      cartItemCount = cartItems.length;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    fetchCartItemCount();  
  }

  Future<void> fetchProducts() async {
    setState(() => isLoading = true);
    final products = await DatabaseService.getAllProducts();
    setState(() {
      allProducts = products;
      isLoading = false;
    });
  }

  List<Product> getFilteredProducts(String category) {
    final filtered =
        allProducts.where((p) {
          return p.category == category &&
              (selectedSubCategory == null ||
                  p.subCategory == selectedSubCategory) &&
              (selectedProductType == null ||
                  p.productType == selectedProductType);
        }).toList();
    return filtered.take(5).toList(); // Showing 5 Products for preview
  }

  void navigateToCategory(String category) {
    final products = allProducts.where((p) => p.category == category).toList();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CategoryViewPage(category: category, products: products),
      ),
    ).then((_) {
      fetchCartItemCount(); 
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Welcome to Diverse Den",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: buttonColor,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => CartPage()))
                    .then((_) => fetchCartItemCount()); 
                },
              ),
              if (cartItemCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: textColor,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 10,
                      minHeight: 10,
                    ),
                    child: Center(
                      child: Text(
                        '$cartItemCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: buttonColor,))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  verticalSpace(10),
                  Center(
                    child: Text(
                      'Products',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  verticalSpace(10),
                  ...categories.map((category) {
                    final filteredProducts = getFilteredProducts(category);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        verticalSpace(10),
                        SizedBox(
                          height: 220,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: filteredProducts.length,
                            itemBuilder: (_, index) {
                              final product = filteredProducts[index];
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ProductDetailPage(
                                        product: product,
                                      ),
                                    ),
                                  ).then((_) {
                                    fetchCartItemCount(); // Refresh cart count on return
                                  });
                                },
                                child: Container(
                                  width: 160,
                                  margin: const EdgeInsets.only(right: 12),
                                  child: Card(                                    
                                    color: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: 10,
                                    shadowColor: buttonColor,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          borderRadius: const BorderRadius.vertical(
                                            top: Radius.circular(16),
                                          ),
                                          child: 
                                          Image.network(
                                            product.imageUrls.isNotEmpty
                                                ? product.imageUrls[0]
                                                : '',
                                            height: 140,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                            loadingBuilder: (context, child, loadingProgress) {
                                              if (loadingProgress == null) return child;
                                              return const SizedBox(
                                                height: 140,
                                                child: Center(
                                                  child: CircularProgressIndicator(strokeWidth: 2,color:buttonColor),
                                                ),
                                              );
                                            },
                                            errorBuilder: (context, error, stackTrace) {
                                              return const SizedBox(
                                                height: 140,
                                                child: Center(
                                                  child: Icon(
                                                    Icons.broken_image,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                product.title,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  color: textColor,
                                                ),
                                              ),
                                              verticalSpace(4),
                                              Text(
                                                'Rs ${product.price}',
                                                style: const TextStyle(
                                                  color: textColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        verticalSpace(5),
                        TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: buttonColor,
                          ),
                          onPressed: () => navigateToCategory(category),
                          child: const Text(
                            'View More',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        verticalSpace(10),
                      ],
                    );
                  }).toList(),
                ],
              ),
            ),
    );
  }
}
