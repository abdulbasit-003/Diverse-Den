import 'package:flutter/material.dart';
import 'package:sample_project/database_service.dart';
import 'package:sample_project/models/variant.dart';
import 'package:sample_project/models/variant_color.dart';
import 'package:sample_project/session_manager.dart';
import '../models/product.dart';
import '../constants.dart';
import 'package:bson/bson.dart';

class ProductDetailPage extends StatefulWidget {
  final Product product;
  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  String? selectedColor;
  String? selectedSize;
  var currentUser;
  bool customerView = true;

  @override
  void initState() {
    super.initState();
    loadSession();
  }

  Future<void> loadSession() async {
    final session = await SessionManager.getUserSession();
    final user = await DatabaseService.getUserByEmail(session['email']!);
    setState(() {
      currentUser = user;
      if (user!['role'] == 'Branch Owner' || user['role'] == 'Admin') {
        customerView = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

  // Get all unique colors from all variants
  final colors = product.variants
      .expand((v) => v.colors.map((c) => c.color))
      .toSet()
      .toList();

  // Get all sizes for the selected color
  final sizesForSelectedColor = product.variants
      .where((v) => v.colors.any((c) => c.color == selectedColor))
      .map((v) => v.size)
      .toSet()
      .toList();

  // Get the quantity for the selected size and color
  final Variant selectedVariant = product.variants.firstWhere(
    (v) => v.size == selectedSize,
    orElse: () => Variant(size: '', colors: []),
  );

  final VariantColor selectedColorVariant = selectedVariant!.colors.firstWhere(
    (c) => c.color == selectedColor,
    orElse: () => VariantColor(color: '', quantity: 0),
  );

  final int quantity = selectedColorVariant!.quantity;

    return Scaffold(
      appBar: AppBar(
        title: Text(product.title, style: const TextStyle(color: fieldBackgroundColor)),
        iconTheme: const IconThemeData(color: fieldBackgroundColor),
        backgroundColor: buttonColor,
      ),
      backgroundColor: fieldBackgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 250,
              child: PageView.builder(
                itemCount: product.imageUrls.length,
                itemBuilder: (context, index) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      product.imageUrls[index],
                      height: 250,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          height: 250,
                          color: Colors.grey[200],
                          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 250,
                          color: Colors.grey[300],
                          child: const Center(
                            child: Icon(Icons.broken_image, size: 40, color: Colors.grey),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            verticalSpace(16),
            Text(product.title,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
            verticalSpace(8),
            Text('Rs ${product.price}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: textColor)),
            verticalSpace(12),
            if (product.category.isNotEmpty)
              Text('Category: ${product.category}', style: const TextStyle(color: textColor)),
            if (product.subCategory != null)
              Text('SubCategory: ${product.subCategory}', style: const TextStyle(color: textColor)),
            if (product.productType.isNotEmpty)
              Text('Product Type: ${product.productType}', style: const TextStyle(color: textColor)),
            verticalSpace(16),
            Text(product.description, style: const TextStyle(color: textColor)),
            verticalSpace(24),

            // Variant selectors
            if (colors.isNotEmpty) ...[
              const Text('Select Color', style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
              DropdownButton<String>(
                value: selectedColor,
                hint: const Text("Choose a color"),
                isExpanded: true,
                items: colors.map((color) {
                  return DropdownMenuItem(value: color, child: Text(color));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedColor = value;
                    selectedSize = null;
                  });
                },
              ),
              verticalSpace(12),
            ],
            if (selectedColor != null && sizesForSelectedColor.isNotEmpty) ...[
              const Text('Select Size', style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
              DropdownButton<String>(
                value: selectedSize,
                hint: const Text("Choose a size"),
                isExpanded: true,
                items: sizesForSelectedColor.map((size) {
                  return DropdownMenuItem(value: size, child: Text(size));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedSize = value;
                  });
                },
              ),
              verticalSpace(12),
            ],
            if (selectedColor != null && selectedSize != null && quantity != null) ...[
              Text('Available Quantity: $quantity', style: const TextStyle(color: textColor)),
              verticalSpace(12),
            ],
            if (customerView)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.add_shopping_cart, color: Colors.white),
                  label: const Text('Add to Cart', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(backgroundColor: buttonColor),
                  onPressed: () async {
                    if (selectedColor == null || selectedSize == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please select color and size')),
                      );
                      return;
                    }

                    try {
                      await DatabaseService.addToCart(
                        userId: currentUser['_id'] as ObjectId, 
                        productId: widget.product.id, 
                        selectedColor: selectedColor!,
                        selectedSize: selectedSize!,
                        quantity: 1,
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Item added to cart')),
                      );
                    } catch (e) {
                      if (e.toString().contains("Out of stock")) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Item is out of stock')),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to add to cart: $e')),
                        );
                      }
                    }
                  }

                ),
              ),
          ],
        ),
      ),
    );
  }
}
