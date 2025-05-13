import 'package:sample_project/constants.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:sample_project/models/cart_item.dart';
import 'package:sample_project/models/product.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:sample_project/session_manager.dart';

class DatabaseService {
  static late Db db;
  static late DbCollection usersCollection;
  static late DbCollection productsCollection;
  static late DbCollection businessesCollection;
  static late DbCollection commentsCollection;
  static late DbCollection cartsCollection;

  static Future<void> connect() async {
    db = await Db.create(
      "mongodb+srv://$dbUser:$dbPass@dd.zrune.mongodb.net/DiverseDen?retryWrites=true&w=majority&appName=DD",
    );
    await db.open();

    usersCollection = db.collection("users");
    productsCollection = db.collection("products");
    businessesCollection = db.collection("businesses");
    commentsCollection = db.collection("comments");
    cartsCollection = db.collection('carts');
  }

  // Find user by email
  static Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    return await usersCollection.findOne(where.eq("email", email));
  }

  // Register user with hashed password
  static Future<void> registerUser(Map<String, dynamic> userData) async {
    userData['password'] = BCrypt.hashpw(
      userData['password'],
      BCrypt.gensalt(),
    );
    await usersCollection.insert(userData);
  }

  // Fetch business details by business ID
  static Future<Map<String, dynamic>?> getBusiness(ObjectId businessId) async {
    return await businessesCollection.findOne(where.eq('_id', businessId));
  }

  // Get Products of a business
  static Future<List<Map<String, dynamic>>> getProducts(ObjectId businessId) {
    return productsCollection.find(where.eq('business', businessId)).toList();
  }

  // Check If Email Already Exists
  static Future<bool> checkIfEmailExists(String email) async {
    var existingUser = await usersCollection.findOne({"email": email});
    return existingUser != null; // Returns true if email exists
  }

  // Check If Phone Already Exists
  static Future<bool> checkIfPhoneExists(String phone) async {
    var existingUser = await usersCollection.findOne({"phone": phone});
    return existingUser != null; // Returns true if phone exists
  }

  // Assign Model to Product
  static Future<void> assignModelToProduct(String sku, String modelPath) async {
    await productsCollection.update(
      where.eq('sku', sku),
      modify.set('modelPath', modelPath),
    );
  }

  static Future<void> initialize3DModelFields(
    String sku,
    ObjectId businessId,
  ) async {
    try {
      await commentsCollection.insertOne({
        "sku": sku,
        "business": businessId,
        "comments": [], // Holds list of comments
        "createdAt": DateTime.now().toUtc(),
      });

      await productsCollection.updateOne(
        where.eq("sku", sku).eq("business", businessId),
        modify..set("likes", []),
      );
    } catch (e) {
      print("Error initializing 3D model fields: $e");
      rethrow;
    }
  }

  // Check if SKU exists in the database for a specific business
  static Future<Map<String, dynamic>?> getProductBySKU(
    String sku,
    ObjectId businessId,
  ) async {
    return await productsCollection.findOne({
      'sku': sku,
      'business': businessId,
    });
  }

  // For getting product for 3D Model
  static Future<Map<String, dynamic>> getProduct(String sku) async {
    final result = await productsCollection.findOne({'sku': sku});
    return result ?? {};
  }

  // // Upload 3D Model Path (only adding address previous method)
  // static Future<void> upload3DModel(String sku, ObjectId businessId, String modelPath) async {
  //   await productsCollection.updateOne(
  //     {'sku': sku, 'business': businessId},
  //     {
  //       '\$set': {'modelPath': modelPath}
  //     },
  //   );
  // }

  // Get All Products with 3D Models
  static Future<List<Map<String, dynamic>>> getProductsWith3DModels() async {
    return await productsCollection.find(where.exists("modelPath")).toList();
  }

  // For Fetching all Products
  static Future<List<Product>> getAllProducts() async {
    try {
      final productsRaw = await productsCollection.find().toList();
      return productsRaw.map((doc) => Product.fromJson(doc)).toList();
    } catch (e) {
      print('Error fetching products: $e');
      return [];
    }
  }

  // Search Products by Title
  static Future<List<Product>> searchProducts(String query) async {
    final results =
        await productsCollection
            .find(where.match('title', query, caseInsensitive: true))
            .toList();
    return results.map((doc) => Product.fromJson(doc)).toList();
  }

  // Search Businesses by Name
  static Future<List<Map<String, dynamic>>> searchBusinesses(
    String query,
  ) async {
    return await businessesCollection
        .find(where.match('name', query, caseInsensitive: true))
        .toList();
  }

  // For product like
  static Future<void> toggleProductLike({
    required ObjectId productId,
    required String customerId,
    required ObjectId businessId,
  }) async {
    try {
      final product = await productsCollection.findOne(
        where.eq('_id', productId),
      );
      if (product == null) return;

      // Ensure likes is always treated as a List
      final rawLikes = product['likes'];
      List<dynamic> likes;

      if (rawLikes is List) {
        likes = rawLikes;
      } else {
        // If stored as an int (like a count), treat it as empty list
        likes = [];
      }

      final isLiked = likes.contains(customerId);

      if (isLiked) {
        likes.remove(customerId);
        await businessesCollection.updateOne(
          where.eq('_id', businessId),
          modify.inc('likes', -1),
        );
      } else {
        likes.add(customerId);
        await businessesCollection.updateOne(
          where.eq('_id', businessId),
          modify.inc('likes', 1),
        );
      }

      await productsCollection.updateOne(
        where.eq('_id', productId),
        modify.set('likes', likes),
      );
    } catch (e) {
      print("Error in toggleProductLike: $e");
      rethrow;
    }
  }

  // Uploading 3D Model to Cloudinary (new method)
  static Future<void> upload3DModel(
    String sku,
    ObjectId businessId,
    String filePath,
  ) async {
    final uri = Uri.parse(
      "https://api.cloudinary.com/v1_1/$cloudName/auto/upload",
    );

    var request =
        http.MultipartRequest('POST', uri)
          ..fields['upload_preset'] = uploadPreset
          ..files.add(await http.MultipartFile.fromPath('file', filePath));

    final response = await request.send();

    if (response.statusCode == 200) {
      final res = await response.stream.bytesToString();
      final data = json.decode(res);

      final modelUrl = data['secure_url']; // Cloudinary model URL

      // Updating my product in MongoDB with this model URL
      await _saveModelUrlToProduct(sku, businessId, modelUrl);
    } else {
      throw Exception(
        'Cloudinary upload failed with status ${response.statusCode}',
      );
    }
  }

  // Saving Model to Product
  static Future<void> _saveModelUrlToProduct(
    String sku,
    ObjectId businessId,
    String modelUrl,
  ) async {
    try {
      await productsCollection.updateOne(
        where.eq('sku', sku).eq('business', businessId),
        modify.set('modelPath', modelUrl),
      );
      print('Model URL saved to product successfully.');
    } catch (e) {
      print('Error saving model URL to product: $e');
      rethrow;
    }
  }

  // Adding Comment to a Product Post
  static Future<void> addComment({
    required String sku,
    required ObjectId businessId,
    required String userId,
    required String text,
  }) async {
    final timestamp = DateTime.now().toUtc().toIso8601String();

    final newComment = {'userId': userId, 'text': text, 'timestamp': timestamp};

    final existingDoc = await commentsCollection.findOne({'sku': sku});

    if (existingDoc != null) {
      await commentsCollection.updateOne(
        where.eq('sku', sku),
        modify.push('comments', newComment),
      );

      // 🔼 Increment comment count in product
      await productsCollection.updateOne(
        where.eq('sku', sku).eq('business', businessId),
        modify.inc('comments', 1),
      );
    } else {
      await commentsCollection.insertOne({
        'sku': sku,
        'business': businessId,
        'comments': [newComment],
        'createdAt': timestamp,
      });

      // 🔼 Set initial comment count = 1 in product
      await productsCollection.updateOne(
        where.eq('sku', sku).eq('business', businessId),
        modify.set('comments', 1),
      );
    }
  }

  // For getting products liked by user
  static Future<List<Map<String, dynamic>>> getLikedProductsByUser(
    String email,
  ) async {
    // Query the database for products liked by the user
    var result =
        await db.collection('products').find({'likes': email}).toList();

    return result;
  }

  static Future<List<Map<String, dynamic>>> getCommentsForSku(
    String sku,
  ) async {
    final commentsDoc = await db.collection('comments').findOne({'sku': sku});
    if (commentsDoc == null || commentsDoc['comments'] == null) return [];

    final List comments = commentsDoc['comments'];
    final userIds = comments.map((c) => c['userId']).toSet().toList();

    final users =
        await db
            .collection('users')
            .find(where.oneFrom('email', userIds))
            .toList();

    final userMap = {for (var user in users) user['email']: user};

    return comments.map<Map<String, dynamic>>((comment) {
      final user = userMap[comment['userId']];
      return {
        'text': comment['text'],
        'timestamp': comment['timestamp'],
        'user':
            user != null
                ? '${user['firstname']} ${user['lastname']}'
                : 'Unknown User',
      };
    }).toList();
  }

  static Future<int> getCommentCountForProduct(String sku) async {
    final collection = db.collection('comments');
    final doc = await collection.findOne({'sku': sku});

    if (doc != null && doc['comments'] is List) {
      return (doc['comments'] as List).length;
    }
    return 0;
  }

  // Toggle follow/unfollow for a business
  static Future<void> toggleFollowBusiness({
    required String customerEmail,
    required ObjectId businessId,
  }) async {
    final customerDoc = await usersCollection.findOne({'email': customerEmail});
    final businessDoc = await businessesCollection.findOne({'_id': businessId});
    if (customerDoc == null || businessDoc == null) return;

    // Ensure followedBusinesses is initialized as a list
    if (customerDoc['followedBusinesses'] == null) {
      await usersCollection.updateOne(
        where.eq('email', customerEmail),
        modify..set("followedBusinesses", []),
      );
      // Reload the updated document
      final updatedDoc = await usersCollection.findOne({
        'email': customerEmail,
      });
      if (updatedDoc == null) return;
      customerDoc['followedBusinesses'] = updatedDoc['followedBusinesses'];
    }
    final followedBusinesses = List<String>.from(
      customerDoc['followedBusinesses'],
    );
    final isFollowing = followedBusinesses.contains(businessId.toHexString());
    if (isFollowing) {
      followedBusinesses.remove(businessId.toHexString());
      await businessesCollection.updateOne(
        {'_id': businessId},
        {
          r'$inc': {'followers': -1},
        },
      );
    } else {
      followedBusinesses.add(businessId.toHexString());
      await businessesCollection.updateOne(
        {'_id': businessId},
        {
          r'$inc': {'followers': 1},
        },
      );
    }

    await usersCollection.updateOne(
      {'email': customerEmail},
      {
        r'$set': {'followedBusinesses': followedBusinesses},
      },
    );
  }

  // Check if a customer is following a business
  static Future<bool> isFollowingBusiness({
    required String customerEmail,
    required ObjectId businessId,
  }) async {
    final customerDoc = await usersCollection.findOne({'email': customerEmail});
    if (customerDoc == null) return false;

    final followed = List<String>.from(customerDoc['followedBusinesses'] ?? []);
    return followed.contains(businessId.toJson());
  }

  // For getting all businesses which are followed by Customer
  static Future<List<String>> getFollowedBusinessIds(String customerId) async {
    final user = await db.collection('users').findOne({'email': customerId});
    if (user == null || user['followedBusinesses'] == null) return [];
    return List<String>.from(user['followedBusinesses']);
  }

  // For deleting a product post
  static Future<void> clearProduct3DData({
    required ObjectId productId,
    required ObjectId businessId,
    required String sku,
    required int likeCount,
  }) async {
    // Remove modelPath, likes, and comments fields from product
    await productsCollection.updateOne(
      where.eq('_id', productId),
      modify.unset('modelPath').unset('likes'),
    );

    // Subtract product's likes from business total likes
    await businessesCollection.updateOne(
      where.eq('_id', businessId),
      modify.inc('likes', -likeCount),
    );

    // Delete related comments document
    await commentsCollection.deleteOne(where.eq('sku', sku));
  }

  static Future<List<CartItem>> getCartItemsForCurrentUser() async {
    final session = await SessionManager.getUserSession();
    final user = await DatabaseService.getUserByEmail(session['email']!);
    final ObjectId userId = user!['_id'];

    final cartDocs = await cartsCollection.find({'userId': userId}).toList();

    List<CartItem> cartItems = [];

    for (var cart in cartDocs) {
      final ObjectId productId = cart['productId'];
      final productData = await productsCollection.findOne({'_id': productId});
      if (productData != null) {
        final product = Product.fromJson(productData);
        cartItems.add(CartItem.fromJson(cart, product));
      }
    }

    return cartItems;
  }

  static Future<void> removeCartItem(ObjectId cartId) async {
    await cartsCollection.deleteOne({'_id': cartId});
  }

  static Future<void> updateCartItemQuantity(ObjectId cartId, int newQty) async {
    await cartsCollection.updateOne(
      where.eq('_id', cartId),
      modify.set('quantity', newQty).set('updatedAt', DateTime.now()),
    );
  }

  static Future<void> addToCart({
    required ObjectId userId,
    required ObjectId productId,
    required String selectedColor,
    required String selectedSize,
    required int quantity,
  }) async {
    final productCollection = db.collection('products');

    // Fetch the product
    final product = await productCollection.findOne({'_id': productId});
    if (product == null) throw Exception("Product not found");

    // Find the correct variant
    final variants = product['variants'] as List<dynamic>;
    final matchingVariant = variants.firstWhere(
      (v) => v['size'] == selectedSize,
      orElse: () => null,
    );

    if (matchingVariant == null) {
      throw Exception("Size variant not found");
    }

    final matchingColor = (matchingVariant['colors'] as List<dynamic>).firstWhere(
      (c) => c['color'] == selectedColor,
      orElse: () => null,
    );

    if (matchingColor == null) {
      throw Exception("Color variant not found");
    }

    final int availableQuantity = matchingColor['quantity'] ?? 0;

    // Check if this item already exists in the cart
    final existingCartItem = await cartsCollection.findOne({
      'userId': userId,
      'productId': productId,
      'selectedVariant.color': selectedColor,
      'selectedVariant.size': selectedSize,
    });

    int totalDesiredQuantity = quantity;
    if (existingCartItem != null) {
      totalDesiredQuantity += existingCartItem['quantity'] as int;
    }

    // If desired quantity exceeds stock
    if (totalDesiredQuantity > availableQuantity) {
      throw Exception("Out of stock");
    }

    // Proceed to add or update in cart
    if (existingCartItem != null) {
      await cartsCollection.updateOne(
        where.eq('_id', existingCartItem['_id']),
        modify
          .inc('quantity', quantity)
          .set('updatedAt', DateTime.now().toUtc()),
      );
    } else {
      await cartsCollection.insertOne({
        'userId': userId,
        'productId': productId,
        'quantity': quantity,
        'selectedVariant': {
          'color': selectedColor,
          'size': selectedSize,
        },
        'createdAt': DateTime.now().toUtc(),
        'updatedAt': DateTime.now().toUtc(),
      });
    }
  }

}
