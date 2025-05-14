import 'package:sample_project/models/variant_color.dart';

class Variant {
  final String size;
  final List<VariantColor> colors;

  Variant({
    required this.size,
    required this.colors,
  });

  factory Variant.fromJson(Map<String, dynamic> json) {
    return Variant(
      size: json['size'] ?? '',
      colors: (json['colors'] as List)
          .map((colorJson) => VariantColor.fromJson(colorJson))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'size': size,
      'colors': colors.map((color) => color.toMap()).toList(),
    };
  }
}
