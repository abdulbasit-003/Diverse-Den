import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:sample_project/constants.dart';
import 'package:sample_project/database_service.dart';
import 'package:sample_project/models/business.dart';
import 'package:sample_project/models/product.dart';
import 'package:sample_project/screens/business_profile_view.dart';
import 'package:sample_project/screens/product_details_page.dart';
import 'package:sample_project/session_manager.dart';
import 'package:sample_project/widgets/icon_with_text.dart';
import 'package:sample_project/widgets/comment_sheet.dart';

class ModelView extends StatefulWidget {
  final Map<String, dynamic> product;

  const ModelView({super.key, required this.product});

  @override
  State<ModelView> createState() => _ModelViewState();
}

class _ModelViewState extends State<ModelView> {
  Map<String, dynamic>? updatedProduct;
  Map<String, dynamic>? business;
  String? currentUserId;
  bool isLiked = false;
  int likeCount = 0;
  int commentCount = 0;
  var currentUser;
  bool customerView = false;

  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<void> initialize() async {
    final session = await SessionManager.getUserSession();
    currentUserId = session['email'];
    final user = await DatabaseService.getUserByEmail(currentUserId!);
    setState(() {
      currentUser = user;
    });
    if (currentUser['role'] == 'Customer') {
      customerView = true;
    }
    await fetchProductAndBusiness();
  }

  Future<void> fetchProductAndBusiness() async {
    final sku = widget.product['sku'];
    final freshProduct = await DatabaseService.getProduct(sku);

    if (freshProduct.isNotEmpty) {
      final businessId = freshProduct['business'];
      final fetchedBusiness = await DatabaseService.getBusiness(businessId);
      final fetchedCommentCount =
          await DatabaseService.getCommentCountForProduct(sku);

      setState(() {
        updatedProduct = freshProduct;
        business = fetchedBusiness;
        likeCount = (freshProduct['likes'] as List?)?.length ?? 0;
        isLiked =
            (freshProduct['likes'] as List?)?.contains(currentUserId) ?? false;
        commentCount = fetchedCommentCount;
      });
    }
  }

  Future<void> handleLike() async {
    if (currentUserId == null || updatedProduct == null) return;

    await DatabaseService.toggleProductLike(
      productId: updatedProduct!['_id'],
      customerId: currentUserId!,
      businessId: updatedProduct!['business'],
    );

    await fetchProductAndBusiness();
  }

  @override
  Widget build(BuildContext context) {
    if (updatedProduct == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: buttonColor)),
      );
    }

    final modelPath = updatedProduct!['modelPath'];
    final name = updatedProduct!['title'] ?? 'No Name';
    final description = updatedProduct!['description'] ?? 'No Description';
    final price = updatedProduct!['price']?.toString() ?? 'N/A';
    final businessName = business?['name'] ?? 'Loading...';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: buttonColor,
        title: Text(name, style: const TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: textColor),
      ),
      body: Stack(
        children: [
          ModelViewer(
            backgroundColor: fieldBackgroundColor,
            src: modelPath,
            alt: "3D Product Model",
            ar: true,
            autoRotate: true,
            cameraControls: true,
          ),
          Positioned(
            left: 16,
            bottom: 20,
            right: 100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextButton(
                  onPressed:
                      business != null
                          ? () {
                            final businessModel = Business(
                              id: business!['_id'],
                              name: business!['name'],
                              description: business!['description'] ?? '',
                              followers: business!['followers'] ?? 0,
                              following: business!['following'] ?? 0,
                              likes: business!['likes'] ?? 0,
                              user: business!['user'],
                            );

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => BusinessProfileView(
                                      business: businessModel,
                                    ),
                              ),
                            );
                          }
                          : null,
                  child: Text(
                    businessName,
                    style: const TextStyle(
                      color: textColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  name,
                  style: const TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: textColor, fontSize: 14),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6),
                  decoration: BoxDecoration(
                    color: Colors.brown,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    "Price: Rs $price",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 10,
            bottom: 120,
            child: Column(
              children: [
                iconWithText(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  likeCount.toString(),
                  handleLike,
                  iconColor: isLiked ? Colors.red : iconColor,
                ),
                const SizedBox(height: 20),
                iconWithText(Icons.comment, commentCount.toString(), () async {
                  await showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => CommentSheet(sku: updatedProduct!['sku']),
                  );

                  await fetchProductAndBusiness();
                }),
                const SizedBox(height: 20),
                (customerView)
                    ? iconWithText(Icons.add_shopping_cart, "Cart", () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder:
                              (ctx) => ProductDetailPage(
                                product: Product.fromJson(updatedProduct!),
                              ),
                        ),
                      );
                    })
                    : Text(''),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
