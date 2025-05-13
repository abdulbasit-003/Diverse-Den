import 'package:flutter/material.dart';
import 'package:sample_project/constants.dart';
import 'package:sample_project/models/cart_item.dart';
import 'package:sample_project/database_service.dart';
import 'package:bson/bson.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<CartItem> cartItems = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCartItems();
  }

  Future<void> fetchCartItems() async {
    final items = await DatabaseService.getCartItemsForCurrentUser();
    setState(() {
      cartItems = items;
      isLoading = false;
    });
  }

  double get totalPrice => cartItems.fold(
    0,
    (sum, item) => sum + item.product.price * item.quantity,
  );

  Future<void> removeItem(ObjectId cartId) async {
    await DatabaseService.removeCartItem(cartId);
    fetchCartItems();
  }

  Future<void> updateQuantity(ObjectId cartId, int newQty, CartItem item) async {
    if (newQty < 1) return;

    final matchingVariant = item.product.variants.firstWhere(
      (variant) => variant.size == item.variant['size'],
      orElse: () => throw Exception('Variant size not found'),
    );

    final matchingColor = matchingVariant.colors.firstWhere(
      (colorVariant) => colorVariant.color == item.variant['color'],
      orElse: () => throw Exception('Color not found for size'),
    );

    final availableQty = matchingColor.quantity;

    if (newQty > availableQty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Only $availableQty available in stock')),
      );
      return;
    }

    await DatabaseService.updateCartItemQuantity(cartId, newQty);
    fetchCartItems();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fieldBackgroundColor,
      appBar: AppBar(
        backgroundColor: buttonColor,
        title: const Text('My Cart', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body:
          isLoading
              ? const Center(
                child: CircularProgressIndicator(color: buttonColor),
              )
              : cartItems.isEmpty
              ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.abc,size: 100,),
                    Text(
                      'Your cart is empty!',
                      style: TextStyle(color: textColor,fontSize: 16),
                    ),
                  ],
                ),
              )
              : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: cartItems.length,
                      itemBuilder: (context, index) {
                        final item = cartItems[index];
                        return Stack(
                          children: [
                            Card(
                              color: Colors.white,
                              shadowColor: buttonColor,
                              elevation: 5,
                              margin: const EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 16,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  top: 8,
                                  right: 8,
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.only(
                                    left: 8,
                                    right: 8,
                                  ),
                                  leading: Image.network(
                                    item.product.imageUrls.isNotEmpty ? item.product.imageUrls[0] : '',
                                    width: 50,
                                  ),
                                  title: Text(item.product.title),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text("Size: ${item.variant['size']}"),
                                      Text("Color: ${item.variant['color']}"),
                                      // Text("Material: null"),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.brown,
                                          borderRadius: BorderRadius.circular(
                                            5,
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 5,
                                        ),
                                        child: Text(
                                          "Rs ${item.product.price}",
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.remove),
                                        onPressed: () => updateQuantity(item.id, item.quantity - 1, item),
                                      ),
                                      Text(item.quantity.toString()),
                                      IconButton(
                                        icon: const Icon(Icons.add),
                                        onPressed: () => updateQuantity(item.id, item.quantity + 1, item),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 0,
                              right: 8,
                              child: GestureDetector(
                                onTap: () => removeItem(item.id),
                                child: const CircleAvatar(
                                  radius: 12,
                                  backgroundColor: Colors.red,
                                  child: Icon(
                                    Icons.close,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Rs ${totalPrice.toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 18),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: buttonColor,
                          ),
                          onPressed: () {
                            // Implement checkout logic
                          },
                          child: const SizedBox(
                            width: double.infinity,
                            child: Center(
                              child: Text(
                                'Checkout',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
    );
  }
}
