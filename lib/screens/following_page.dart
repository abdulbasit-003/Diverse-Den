import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:sample_project/constants.dart';
import 'package:sample_project/database_service.dart';
import 'package:sample_project/models/product.dart';
import 'package:sample_project/screens/product_details_page.dart';
import 'package:sample_project/session_manager.dart';
import 'package:sample_project/widgets/icon_with_text.dart';
import 'package:sample_project/widgets/comment_sheet.dart';

class FollowingPage extends StatefulWidget {
  const FollowingPage({super.key});

  @override
  State<FollowingPage> createState() => _FollowingPageState();
}

class _FollowingPageState extends State<FollowingPage> {
  List<Map<String, dynamic>> products = [];
  bool isLoading = true;
  String? currentUserId;
  Map<String, int> commentCounts = {};

  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<void> initialize() async {
    final session = await SessionManager.getUserSession();
    setState(() {
      currentUserId = session['email'];
    });
    await fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      final allProducts = await DatabaseService.getProductsWith3DModels();
      print(allProducts);
      final followedBusinessIds = await DatabaseService.getFollowedBusinessIds(
        currentUserId!,
      );

      final filtered =
          allProducts
              .where(
                (product) =>
                    followedBusinessIds.contains(product['business'].toJson()),
              )
              .toList();
      print(filtered);
      Map<String, int> counts = {};
      for (var product in filtered) {
        final sku = product['sku'];
        final count = await DatabaseService.getCommentCountForProduct(sku);
        counts[sku] = count;
      }

      setState(() {
        products = filtered;
        commentCounts = counts;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching followed products: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Map<String, String> getLikesAndCommentsCount(Map<String, dynamic> product) {
    int likes = 0;
    int comments = 0;

    final rawLikes = product['likes'];
    final rawComments = product['comments'];

    if (rawLikes is List) likes = rawLikes.length;
    if (rawLikes is int) likes = rawLikes;
    if (rawComments is List) comments = rawComments.length;
    if (rawComments is int) comments = rawComments;

    return {'likes': likes.toString(), 'comments': comments.toString()};
  }

  bool isLikedByCurrentUser(Map<String, dynamic> product) {
    if (currentUserId == null) return false;
    final rawLikes = product['likes'];
    return rawLikes is List && rawLikes.contains(currentUserId);
  }

  Future<void> handleLike(Map<String, dynamic> product) async {
    if (currentUserId == null) return;
    final productId = product['_id'];
    final businessId = product['business'];

    await DatabaseService.toggleProductLike(
      productId: productId,
      customerId: currentUserId!,
      businessId: businessId,
    );

    await fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator(color: textColor))
              : products.isEmpty
              ? const Center(
                child: Text(
                  "Try Following businesses with 3D Models!",
                  style: TextStyle(fontSize: 18, color: textColor),
                ),
              )
              : PageView.builder(
                scrollDirection: Axis.vertical,
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  final modelPath = product["modelPath"];
                  final name = product["title"] ?? "No Name";
                  final description =
                      product["description"] ?? "No Description";
                  final businessId = product["business"];
                  final price = product["price"]?.toString() ?? "N/A";
                  final likes = getLikesAndCommentsCount(product)['likes'];
                  final comments =
                      commentCounts[product['sku']]?.toString() ?? '0';
                  final isLiked = isLikedByCurrentUser(product);

                  return FutureBuilder(
                    future: DatabaseService.getBusiness(businessId),
                    builder: (context, snapshot) {
                      final businessName =
                          snapshot.hasData
                              ? (snapshot.data?['name'] ?? 'Unknown Business')
                              : 'Loading...';

                      return Stack(
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
                                Text(
                                  businessName,
                                  style: const TextStyle(
                                    color: textColor,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
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
                                  style: const TextStyle(
                                    color: textColor,
                                    fontSize: 14,
                                  ),
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
                                  isLiked
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  likes!,
                                  () => handleLike(product),
                                  iconColor: isLiked ? Colors.red : iconColor,
                                ),
                                const SizedBox(height: 20),
                                iconWithText(Icons.comment, comments, () async {
                                  await showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    builder:
                                        (_) =>
                                            CommentSheet(sku: product['sku']),
                                  );
                                  await fetchProducts(); // Refresh comment count
                                }),
                                const SizedBox(height: 20),
                                iconWithText(Icons.add_shopping_cart, "", () {
                                  Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => ProductDetailPage(product: Product.fromJson(product),),),);
                                }),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
    );
  }
}
