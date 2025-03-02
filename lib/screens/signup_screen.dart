import 'package:flutter/material.dart';
import 'package:diverseden/database_service.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});
  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  String? message;

  void registerUser() async {
    await DatabaseService.connect();

    Map<String, dynamic> newUser = {
      "firstname": firstNameController.text,
      "lastname": lastNameController.text,
      "email": emailController.text,
      "phone": phoneController.text,
      "password": passwordController.text, // This will be hashed in database_service.dart
      "role": "Customer", // Default role
      "createdAt": DateTime.now().millisecondsSinceEpoch,
      "updatedAt": DateTime.now().millisecondsSinceEpoch
    };

    await DatabaseService.registerUser(newUser);

    setState(() {
      message = "Signup successful!";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Signup")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: firstNameController, decoration: InputDecoration(labelText: "First Name")),
            TextField(controller: lastNameController, decoration: InputDecoration(labelText: "Last Name")),
            TextField(controller: emailController, decoration: InputDecoration(labelText: "Email")),
            TextField(controller: phoneController, decoration: InputDecoration(labelText: "Phone")),
            TextField(controller: passwordController, decoration: InputDecoration(labelText: "Password"), obscureText: true),
            SizedBox(height: 20),
            ElevatedButton(onPressed: registerUser, child: Text("Signup")),
            SizedBox(height: 20),
            Text(message ?? ""),
          ],
        ),
      ),
    );
  }
}
