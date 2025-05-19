import 'package:flutter/material.dart';
import 'package:sample_project/constants.dart';
import 'package:sample_project/database_service.dart';

class CheckoutPage extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final Map<String, dynamic> userData;

  const CheckoutPage({
    super.key,
    required this.cartItems,
    required this.userData,
  });

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  bool isFirstNameEmpty = false;
  bool isLastNameEmpty = false;
  bool isEmailEmpty = false;
  bool isPhoneEmpty = false;
  bool isAddressEmpty = false;
  bool isCityEmpty = false;
  
  bool isPlacingOrder = false;
  String selectedPaymentMethod = 'cashOnDelivery';
  double shippingCost = finalShippingCost;

  @override
  void initState() {
    super.initState();
    firstNameController.text = widget.userData['firstname'] ?? '';
    lastNameController.text = widget.userData['lastname'] ?? '';
    emailController.text = widget.userData['email'] ?? '';
    phoneController.text = widget.userData['phone']?.toString() ?? '';
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    cityController.dispose();
    super.dispose();
  }

  double get subTotal {
    double total = 0;
    for (var item in widget.cartItems) {
      final price = double.tryParse(item['product']['price'].toString()) ?? 0;
      final quantity = int.tryParse(item['quantity'].toString()) ?? 1;
      total += price * quantity;
    }
    return total;
  }

  Future<void> _placeOrders() async {
    setState(() {
      isPlacingOrder = true;

      // Validate input fields
      isFirstNameEmpty = firstNameController.text.trim().isEmpty;
      isLastNameEmpty = lastNameController.text.trim().isEmpty;
      isEmailEmpty = emailController.text.trim().isEmpty;
      isPhoneEmpty = phoneController.text.trim().isEmpty;
      isAddressEmpty = addressController.text.trim().isEmpty;
      isCityEmpty = cityController.text.trim().isEmpty;
    });

    if (isFirstNameEmpty || isLastNameEmpty || isEmailEmpty || isPhoneEmpty || isAddressEmpty || isCityEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Missing Information"),
          content: const Text("Please enter all details."),
          actions: [
            TextButton(
              style: TextButton.styleFrom(backgroundColor: buttonColor),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
      setState(() => isPlacingOrder = false);
      return;
    }

    final firstname = firstNameController.text.trim();
    final lastname = lastNameController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();
    final address = addressController.text.trim();
    final city = cityController.text.trim();

    final userInfo = {
      "firstname": firstname,
      "lastname": lastname,
      "email": email,
      "phone": phone,
      "address": address,
      "city": city,
      "paymentMethod": selectedPaymentMethod,
    };

    // ✅ Group cart items by businessId
    final Map<String, List<Map<String, dynamic>>> groupedItems = {};

    for (var item in widget.cartItems) {
      final product = item['product'];
      final productId = product['_id'];

      final businessId = await DatabaseService.getBusinessIdByProductId(productId);
      if (businessId == null) continue;

      final businessIdStr = businessId.toHexString();
      final updatedItem = Map<String, dynamic>.from(item);
      updatedItem['businessId'] = businessId;

      groupedItems.putIfAbsent(businessIdStr, () => []).add(updatedItem);
    }

    try {
      for (final entry in groupedItems.entries) {
        final businessId = entry.key;
        final items = entry.value;
        await DatabaseService.placeOrder(
          businessId: businessId,
          address: address,
          city: city,
          cartItems: items,
          userInfo: userInfo,
          paymentMethod: selectedPaymentMethod,
        );
      }

      final userId = await DatabaseService.getCurrentUserId();
      await DatabaseService.clearUserCart(userId);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order placed successfully!')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to place order: $e')),
      );
    } finally {
      setState(() => isPlacingOrder = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = subTotal + shippingCost;

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, -2),
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _summaryRow("Subtotal", subTotal),
            _summaryRow("Shipping", shippingCost),
            _summaryRow("Total", total, isBold: true),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: isPlacingOrder ? null : _placeOrders,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: buttonColor,
              ),
              child: isPlacingOrder
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Place Order", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: const Text('Checkout', style: TextStyle(color: Colors.white)),
        backgroundColor: buttonColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cart Items Display
            const Text('Your Items', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ListView.builder(
              itemCount: widget.cartItems.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final item = widget.cartItems[index];
                final product = item['product'];
                final quantity = item['quantity'];
                final title = product['title'] ?? '';
                final image = (product['imagePath'] != null && product['imagePath'].isNotEmpty)
                    ? product['imagePath'][0]
                    : null;
                final price = product['price'] ?? 0;

                return ListTile(
                  leading: image != null
                      ? Image.network(image, width: 50, height: 50, fit: BoxFit.cover)
                      : const Icon(Icons.image),
                  title: Text(title),
                  subtitle: Text('Qty: $quantity'),
                  trailing: Text('Rs. ${(price * quantity).toString()}'),
                );
              },
            ),

            const Divider(height: 32),
            const Text("Customer Info", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _inputField("First Name", firstNameController, isFirstNameEmpty),
            _inputField("Last Name", lastNameController, isLastNameEmpty),
            _inputField("Email", emailController, isEmailEmpty),
            _inputField("Phone", phoneController, isPhoneEmpty),
            _inputField("Address", addressController, isAddressEmpty),
            _inputField("City", cityController, isCityEmpty),

            const SizedBox(height: 24),
            const Text("Payment Method", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              dropdownColor: Colors.white,
              value: selectedPaymentMethod,
              items: const [
                DropdownMenuItem(value: 'cashOnDelivery', child: Text("Cash on Delivery")),
                DropdownMenuItem(value: 'stripe', child: Text("Stripe")),
              ],
              onChanged: (value) => setState(() => selectedPaymentMethod = value!),
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),

            const Divider(height: 32),
            // const Text("Summary", style: TextStyle(fontWeight: FontWeight.bold)),
            // const SizedBox(height: 8),
            // _summaryRow("Subtotal", subTotal),
            // _summaryRow("Shipping", shippingCost),
            // _summaryRow("Total", total, isBold: true),

            // const SizedBox(height: 24),
            // ElevatedButton(
            //   onPressed: isPlacingOrder ? null : _placeOrders,
            //   style: ElevatedButton.styleFrom(
            //     minimumSize: const Size.fromHeight(50),
            //     backgroundColor: buttonColor,
            //   ),
            //   child: isPlacingOrder
            //       ? const CircularProgressIndicator(color: Colors.white)
            //       : const Text("Place Order", style: TextStyle(color: Colors.white)),
            // )
          ],
        ),
      ),
    );
  }

  Widget _inputField(String label, TextEditingController controller, bool isError) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: isError ? Colors.red : buttonColor, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: isError ? Colors.red : Colors.grey),
          ),
        ),
      ),
    );
  }

  Widget _summaryRow(String label, double amount, {bool isBold = false}) {
    final textStyle = isBold ? const TextStyle(fontWeight: FontWeight.bold) : null;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: textStyle),
          Text("Rs. ${amount.toStringAsFixed(2)}", style: textStyle),
        ],
      ),
    );
  }
}
