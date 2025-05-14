import 'package:flutter/material.dart';
import 'package:sample_project/constants.dart';
import 'package:bson/bson.dart';
import 'package:sample_project/database_service.dart';

class CheckoutPage extends StatefulWidget {
  final ObjectId userId;
  final Map<String, dynamic> userInfo;
  final List<Map<String, dynamic>> cartItems;

  const CheckoutPage({
    super.key,
    required this.userId,
    required this.userInfo,
    required this.cartItems,
  });

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  bool isPlacingOrder = false;
  double shippingCost = finalShippingCost;

  void _placeOrders() async {
    setState(() => isPlacingOrder = true);

    try {
      // Group cart items by businessId
      final Map<ObjectId, List<Map<String, dynamic>>> itemsByBusiness = {};

      for (var item in widget.cartItems) {
        final product = item['product'];
        final businessHex = product['business'];

        if (businessHex == null || businessHex is! String) {
          throw Exception("Invalid or missing business ID in product: ${product['title']}");
        }

        final businessId = ObjectId.fromHexString(businessHex);

        itemsByBusiness.putIfAbsent(businessId, () => []).add(item);
      }


      for (var entry in itemsByBusiness.entries) {
        final businessId = entry.key;
        final items = entry.value;

        double subTotal = 0;

        for (var item in items) {
          final price =
              double.tryParse(item['product']['price'].toString()) ?? 0;
          final quantity = int.tryParse(item['quantity'].toString()) ?? 1;
          subTotal += price * quantity;
        }

        double totalAmount = subTotal + shippingCost;

        await DatabaseService.placeOrder(
          orderType: 'Online',
          userId: widget.userId,
          userInfo: {...widget.userInfo, 'paymentMethod': 'cashOnDelivery'},
          cartItems: items,
          subTotal: subTotal,
          shippingCost: shippingCost,
          totalAmount: totalAmount,
          businessId: businessId,
          branchCode: '',
        );
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Order(s) placed successfully!')));

      Navigator.pop(context);
    } catch (e) {
      print('Error placing orders: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Order Placed Successfully')));
    } finally {
      setState(() => isPlacingOrder = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    double subTotal = 0;
    for (var item in widget.cartItems) {
      final price = double.tryParse(item['product']['price'].toString()) ?? 0;
      final quantity = int.tryParse(item['quantity'].toString()) ?? 1;
      subTotal += price * quantity;
    }

    double totalAmount = subTotal + shippingCost;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Checkout', style: TextStyle(color: Colors.white)),
        backgroundColor: buttonColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Shipping Address:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(widget.userInfo['address'] ?? ''),
            const Divider(height: 32),

            Expanded(
              child: ListView.builder(
                itemCount: widget.cartItems.length,
                itemBuilder: (context, index) {
                  final item = widget.cartItems[index];
                  final product = item['product'];
                  final quantity = item['quantity'];

                  final title = product['title'] ?? '';
                  final image =
                      (product['imagePath'] != null &&
                              product['imagePath'].isNotEmpty)
                          ? product['imagePath'][0]
                          : null;
                  final price = product['price'] ?? 0;

                  return ListTile(
                    leading:
                        image != null
                            ? Image.network(
                              image,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            )
                            : Icon(Icons.image),
                    title: Text(title),
                    subtitle: Text('Qty: $quantity'),
                    trailing: Text('Rs. ${(price * quantity).toString()}'),
                  );
                },
              ),
            ),

            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Subtotal'),
                Text('Rs. ${subTotal.toStringAsFixed(2)}'),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Shipping'),
                Text('Rs. ${shippingCost.toStringAsFixed(2)}'),
              ],
            ),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  'Rs. ${totalAmount.toStringAsFixed(2)}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: buttonColor),
              onPressed: isPlacingOrder ? null : _placeOrders,
              child:
                  isPlacingOrder
                      ? CircularProgressIndicator(color: buttonColor)
                      : Text('Place Order',style: TextStyle(color: Colors.white),),
            ),
          ],
        ),
      ),
    );
  }
}
