class VariantColor {
  final String color;
  final int quantity;

  VariantColor({
    required this.color,
    required this.quantity,
  });

  factory VariantColor.fromJson(Map<String, dynamic> json) {
    return VariantColor(
      color: json['color'] ?? '',
      quantity: json['quantity'] is int ? json['quantity'] : int.tryParse(json['quantity'].toString()) ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'color': color,
      'quantity': quantity,
    };
  }
}
