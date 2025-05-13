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

class ForYouPage extends StatefulWidget {
  const ForYouPage({super.key});

  @override
  State<ForYouPage> createState() => _ForYouPageState();
}

class _ForYouPageState extends State<ForYouPage> {
  List<Map<String, dynamic>> products = [];
  bool isLoading = true;
  String? currentUserId;
  Map<String, int> commentCounts = {};
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
      currentUserId = session['email'];
      currentUser = user;
    });

    if (currentUser['role'] == 'Customer') {
      customerView = true;
    }

    await fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      var fetchedProducts = await DatabaseService.getProductsWith3DModels();

      // Fetching comment counts for each product
      Map<String, int> counts = {};
      for (var product in fetchedProducts) {
        final sku = product['sku'];
        final count = await DatabaseService.getCommentCountForProduct(sku);
        counts[sku] = count;
      }

      setState(() {
        products = fetchedProducts;
        commentCounts = counts;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching products or comment counts: $e");
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

    if (rawLikes is List) {
      likes = rawLikes.length;
    } else if (rawLikes is int) {
      likes = rawLikes;
    }

    if (rawComments is List) {
      comments = rawComments.length;
    } else if (rawComments is int) {
      comments = rawComments;
    }

    return {'likes': likes.toString(), 'comments': comments.toString()};
  }

  bool isLikedByCurrentUser(Map<String, dynamic> product) {
    if (currentUserId == null) return false;
    final rawLikes = product['likes'];
    if (rawLikes is List) {
      return rawLikes.contains(currentUserId);
    }
    return false;
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
                  "No 3D models available!",
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
                          // Product Info (left bottom)
                          Positioned(
                            left: 16,
                            bottom: 20,
                            right: 100,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    if (snapshot.hasData) {
                                      final businessMap = snapshot.data!;
                                      final business = Business(
                                        id: businessMap['_id'],
                                        name: businessMap['name'],
                                        description:
                                            businessMap['description'] ?? '',
                                        followers:
                                            businessMap['followers'] ?? 0,
                                        following:
                                            businessMap['following'] ?? 0,
                                        likes: businessMap['likes'] ?? 0,
                                      );

                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (_) => BusinessProfileView(
                                                business: business,
                                              ),
                                        ),
                                      );
                                    }
                                  },
                                  child: Text(
                                    "$businessName",
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

                          // Action Buttons (right bottom)
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

                                  await fetchProducts();
                                }),
                                const SizedBox(height: 20),
                                (customerView)
                                    ? iconWithText(
                                      Icons.add_shopping_cart,
                                      "",
                                      () {
                                        final productObj = Product.fromJson(product);
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => ProductDetailPage(product: productObj),
                                          ),
                                        );
                                      },
                                    )
                                    : Text(''),
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
