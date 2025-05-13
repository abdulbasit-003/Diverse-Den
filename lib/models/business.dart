import 'package:mongo_dart/mongo_dart.dart';

class Business {
  final ObjectId id;
  final String name;
  final String description;
  final int followers;
  final int following;
  final int likes;

  Business({
    required this.id,
    required this.name,
    required this.description,
    required this.followers,
    required this.following,
    required this.likes,
  });

  factory Business.fromJson(Map<String, dynamic> json) {
    return Business(
      id: json['_id'] as ObjectId,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      followers: json['followers'] ?? 0,
      following: json['following'] ?? 0,
      likes: json['likes'] ?? 0,
    );
  }
  
}
