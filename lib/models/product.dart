import 'package:sample_project/models/variant.dart';
import 'package:bson/bson.dart';

class Product {
  final String title;
  final int price;
  final List<String> imageUrls; // <-- Update this
  final String description;
  final String category;
  final String? subCategory;
  final String productType;
  final List<Variant> variants;
  final ObjectId id;

  Product({
    required this.title,
    required this.price,
    required this.imageUrls,
    required this.description,
    required this.category,
    this.subCategory,
    required this.productType,
    required this.variants,
    required this.id,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      price: json['price'] is int ? json['price'] : int.tryParse(json['price'].toString()) ?? 0,
      imageUrls: json['imagePath'] != null && json['imagePath'] is List
          ? List<String>.from(json['imagePath'])
          : [],
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      subCategory: json['subCategory'],
      productType: json['productType'] ?? '',
      variants: (json['variants'] as List)
          .map((variant) => Variant.fromJson(variant))
          .toList(),
    );
  }
}
