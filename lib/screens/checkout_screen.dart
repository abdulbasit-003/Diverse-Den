// import 'package:flutter/material.dart';
// import 'package:sample_project/database_service.dart';
// import 'package:sample_project/models/cart_item.dart';
// import 'package:sample_project/session_manager.dart';

// class CheckoutPage extends StatefulWidget {
//   @override
//   _CheckoutPageState createState() => _CheckoutPageState();
// }

// class _CheckoutPageState extends State<CheckoutPage> {
//   late List<CartItem> cartItems;
//   late double totalAmount;
//   String paymentMethod = 'Stripe';

//   // Controllers for input fields
//   final TextEditingController firstNameController = TextEditingController();
//   final TextEditingController lastNameController = TextEditingController();
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController addressController = TextEditingController();
//   final TextEditingController cityController = TextEditingController();
//   final TextEditingController phoneController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     _loadCartItems();
//   }

//   // Load cart items from the database
//   void _loadCartItems() async {
//     cartItems = await DatabaseService.getCartItemsForCurrentUser();
//     totalAmount = cartItems.fold(
//       0.0,
//       (sum, item) => sum + (item.product.price * item.quantity),
//     );
//     setState(() {});
//   }

//   // Place the order and clear cart
//   void _placeOrder() async {
//     final session = await SessionManager.getUserSession();
//     final user = await DatabaseService.getUserByEmail(session['email']!);

//     final order = {
//       'userId': user!['_id'],
//       'cartItems': cartItems.map((item) => {
//         'productId': item.product.id,
//         'quantity': item.quantity,
//         'variant': item.selectedVariant,
//       }).toList(),
//       'totalAmount': totalAmount,
//       'paymentMethod': paymentMethod,
//       'shippingInfo': {
//         'firstName': firstNameController.text,
//         'lastName': lastNameController.text,
//         'email': emailController.text,
//         'address': addressController.text,
//         'city': cityController.text,
//         'phone': phoneController.text,
//       },
//       'status': 'Pending',
//       'orderDate': DateTime.now(),
//     };

//     // Save the order
//     await DatabaseService.placeOrder(order);

//     // Clear the cart
//     await DatabaseService.clearCartForUser(user['_id']);

//     // Navigate to order confirmation screen or similar
//     Navigator.pushNamed(context, '/orderConfirmation');
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Checkout')),
//       body: cartItems.isEmpty
//           ? Center(child: CircularProgressIndicator())
//           : SingleChildScrollView(
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Order Summary
//                     Text('Order Summary', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
//                     ...cartItems.map((item) {
//                       return ListTile(
//                         title: Text(item.product.title),
//                         subtitle: Text("Quantity: ${item.quantity}"),
//                         trailing: Text("\$${item.quantity * item.product.price}"),
//                       );
//                     }).toList(),
//                     Divider(),
//                     ListTile(
//                       title: Text("Total Amount"),
//                       trailing: Text("\$$totalAmount"),
//                     ),
//                     SizedBox(height: 20),

//                     // Shipping Info
//                     Text('Shipping Information', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//                     TextFormField(
//                       controller: firstNameController,
//                       decoration: InputDecoration(labelText: "First Name"),
//                       validator: (value) => value!.isEmpty ? "Enter your first name" : null,
//                     ),
//                     TextFormField(
//                       controller: lastNameController,
//                       decoration: InputDecoration(labelText: "Last Name"),
//                       validator: (value) => value!.isEmpty ? "Enter your last name" : null,
//                     ),
//                     TextFormField(
//                       controller: emailController,
//                       decoration: InputDecoration(labelText: "Email"),
//                       validator: (value) => value!.isEmpty ? "Enter your email" : null,
//                     ),
//                     TextFormField(
//                       controller: addressController,
//                       decoration: InputDecoration(labelText: "Address"),
//                       validator: (value) => value!.isEmpty ? "Enter your address" : null,
//                     ),
//                     TextFormField(
//                       controller: cityController,
//                       decoration: InputDecoration(labelText: "City"),
//                       validator: (value) => value!.isEmpty ? "Enter your city" : null,
//                     ),
//                     TextFormField(
//                       controller: phoneController,
//                       decoration: InputDecoration(labelText: "Phone"),
//                       validator: (value) => value!.isEmpty ? "Enter your phone" : null,
//                     ),
//                     SizedBox(height: 20),

//                     // Payment Method Selector
//                     Text('Payment Method', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//                     ListTile(
//                       title: Text("Stripe"),
//                       leading: Radio<String>(
//                         value: 'Stripe',
//                         groupValue: paymentMethod,
//                         onChanged: (value) {
//                           setState(() {
//                             paymentMethod = value!;
//                           });
//                         },
//                       ),
//                     ),
//                     ListTile(
//                       title: Text("Cash on Delivery (COD)"),
//                       leading: Radio<String>(
//                         value: 'COD',
//                         groupValue: paymentMethod,
//                         onChanged: (value) {
//                           setState(() {
//                             paymentMethod = value!;
//                           });
//                         },
//                       ),
//                     ),
//                     SizedBox(height: 20),

//                     // Place Order Button
//                     ElevatedButton(
//                       onPressed: _placeOrder,
//                       child: Text("Place Order"),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//     );
//   }
// }
