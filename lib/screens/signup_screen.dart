import 'package:flutter/material.dart';
import 'package:sample_project/database_service.dart';
import 'package:sample_project/screens/login_screen.dart';
import 'package:sample_project/widgets/text_field_widget.dart';
import 'package:sample_project/constants.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  String? message;

  void registerUser() async {
  String email = emailController.text.trim();
  String phone = phoneController.text.trim();
  String password = passwordController.text;
  String confirmPassword = confirmPasswordController.text;

  // All Fields are filled
  if (firstNameController.text.isEmpty || lastNameController.text.isEmpty || emailController.text.isEmpty || passwordController.text.isEmpty || confirmPasswordController.text.isEmpty) {
      setState(() {
        message = "Please fill in all fields!";
      });
      return;
    }

  // Passwords must match
  if (password != confirmPassword) {
    setState(() {
      message = "Passwords do not match!";
    });
    return;
  }

  // Email format validation
  RegExp emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
  if (!emailRegex.hasMatch(email)) {
    setState(() {
      message = "Invalid email format!";
    });
    return;
  }

  // Phone number must be exactly 11 digits
  if (phone.length != 11 || !RegExp(r'^[0-9]+$').hasMatch(phone)) {
    setState(() {
      message = "Phone number does not exist.";
    });
    return;
  }

  await DatabaseService.connect();

  // Check if email already exists
  bool emailExists = await DatabaseService.checkIfEmailExists(email);
  if (emailExists) {
    setState(() {
      message = "Email already exists!";
    });
    return;
  }

  // Check if phone number already exists
  bool phoneExists = await DatabaseService.checkIfPhoneExists(phone);
  if (phoneExists) {
    setState(() {
      message = "Phone number already exists!";
    });
    return;
  }

  // Save User in Database
  Map<String, dynamic> newUser = {
    "firstname": firstNameController.text,
    "lastname": lastNameController.text,
    "email": email,
    "phone": phone,
    "password": password, // This will be hashed in database_service.dart
    "role": "Customer",
    "createdAt": DateTime.now().millisecondsSinceEpoch,
    "updatedAt": DateTime.now().millisecondsSinceEpoch
  };

  await DatabaseService.registerUser(newUser);
  setState(() {
    message = "";
  });
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Signed Up!"),
        content: const Text("Sign Up Successful. Now you can login!"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (ctx) => const LoginPage()),
              );
            },
            child: const Text("Proceed"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Already have an account?"),
          TextButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (ctx) => const LoginPage()),
              );
            },
            child: const Text("Login Here", style: TextStyle(color: textColor)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Image.asset(logo, height: 100, width: 100),
              const SizedBox(height: 10),
              const Text("Diverse Den", style: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              const Text("Register into Diverse Den", style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 15),
              TextFieldWidget(icon: Icons.person, label: const Text("Enter First Name"), obscure: false, controller: firstNameController),
              const SizedBox(height: 10),
              TextFieldWidget(icon: Icons.person, label: const Text("Enter Last Name"), obscure: false, controller: lastNameController),
              const SizedBox(height: 10),
              TextFieldWidget(icon: Icons.email, label: const Text("Enter Email"), obscure: false, controller: emailController, keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 10),
              TextFieldWidget(icon: Icons.lock, label: const Text("Enter Password"), obscure: true, controller: passwordController),
              const SizedBox(height: 10),
              TextFieldWidget(icon: Icons.lock, label: const Text("Confirm Password"), obscure: true, controller: confirmPasswordController),
              const SizedBox(height: 10),
              TextFieldWidget(icon: Icons.phone, label: const Text("Enter Phone No."), obscure: false, controller: phoneController, keyboardType: TextInputType.phone),
              const SizedBox(height: 15),
              ElevatedButton(
                style: const ButtonStyle(backgroundColor: WidgetStatePropertyAll(buttonColor)),
                onPressed: registerUser,
                child: const Text("Sign Up", style: TextStyle(color: Colors.white)),
              ),
              if (message != null) const SizedBox(height: 10),
              if (message != null) Text(message!, style: const TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ),
    );
  }
}
