import 'package:bson/bson.dart';
import 'product.dart';

class CartItem {
  final ObjectId id;
  final ObjectId userId;
  final ObjectId productId;
  final Product product;
  final int quantity;
  final Map<String, dynamic> variant;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CartItem({
    required this.id,
    required this.userId,
    required this.productId,
    required this.product,
    required this.quantity,
    required this.variant,
    this.createdAt,
    this.updatedAt,
  });

  factory CartItem.fromJson(Map<String, dynamic> json, Product product) {
    return CartItem(
      id: json['_id'] as ObjectId,
      userId: json['userId'] as ObjectId,
      productId: json['productId'] as ObjectId,
      product: product,
      quantity: json['quantity'] as int,
      variant: Map<String, dynamic>.from(json['selectedVariant'] ?? {}),
      createdAt: DateTime.parse(json['createdAt'].toString()),
      updatedAt: DateTime.parse(json['updatedAt'].toString()),
    );
  }
  Map<String, dynamic> toMap() {
  return {
    'userId': userId, // should be ObjectId or String
    'productId': product.id,
    'selectedVariant': variant, // assumed to be a Map with color, size, etc.
    'quantity': quantity,
    'product': product.toMap(), // assuming your Product model also has toMap()
  };
}
}
