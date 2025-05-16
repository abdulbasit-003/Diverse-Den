import 'package:flutter/material.dart';
import 'package:sample_project/constants.dart';
import 'package:sample_project/screens/model_view.dart';
import 'package:sample_project/database_service.dart';

class OwnerProductCard extends StatelessWidget {
  final Map<String, dynamic> product;

  const OwnerProductCard({super.key, required this.product});

  Future<void> _deleteProductData(BuildContext context) async {
    final bool confirmed = await showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            backgroundColor: Colors.white,
            title: const Text('Delete 3D Model?'),
            content: const Text(
              'Are you sure you want to delete the 3D model of this product? This cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: buttonColor),
                ),
              ),
              TextButton(
                style: TextButton.styleFrom(backgroundColor: buttonColor),
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Yes', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
    );

    if (!confirmed) return;

    final productId = product['_id'];
    final sku = product['sku'];
    final businessId = product['business'];
    final likes = (product['likes'] as List?) ?? [];

    try {
      await DatabaseService.clearProduct3DData(
        productId: productId,
        businessId: businessId,
        sku: sku,
        likeCount: likes.length,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('3D Product data deleted successfully!'),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Connection failure!')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = product['title'] ?? 'No Name';
    final price = product['price']?.toString() ?? 'N/A';
    final image = product['imagePath']?.first ?? '';
    final modelPath = product['modelPath'];

    return GestureDetector(
      onTap: () {
        if (modelPath != null && modelPath.isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ModelView(product: product)),
          );
        }
      },
      onLongPress: () => _deleteProductData(context),
      child: Card(
        color: Colors.white,
        elevation: 10,
        shadowColor: buttonColor,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Image.network(
                  image,
                  height: 130,
                  width: 130,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stackTrace) =>
                          const Icon(Icons.broken_image, size: 130),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(
                  color: Colors.brown,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  "Rs $price",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
