import 'package:flutter/material.dart';
import 'package:sample_project/models/product.dart';
import 'package:sample_project/screens/product_details_page.dart';
import 'package:sample_project/constants.dart';

class CategoryViewPage extends StatelessWidget {
  final String category;
  final List<Product> products;

  const CategoryViewPage({
    super.key,
    required this.category,
    required this.products,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$category Products',style: TextStyle(color: Colors.white),),
        backgroundColor: buttonColor,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.72,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: products.length,
        itemBuilder: (_, index) {
          final product = products[index];
          return GestureDetector(
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProductDetailPage(product: product),
                  ),
                ),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              shadowColor: buttonColor,
              color: Colors.white,
              elevation: 5,
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: Image.network(
                      product.imageUrls.isNotEmpty ? product.imageUrls[0] : '',
                      height: 140,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          height: 140,
                          width: double.infinity,
                          color: Colors.grey[200],
                          child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2,color: buttonColor,),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 140,
                          width: double.infinity,
                          color: Colors.white,
                          child: const Center(
                            child: Icon(
                              Icons.broken_image,
                              size: 40,
                              color: Colors.white,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Text(
                          product.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: textColor),
                        ),
                        verticalSpace(4),
                        Text(
                          'Rs ${product.price}',
                          style: const TextStyle(color: textColor),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
