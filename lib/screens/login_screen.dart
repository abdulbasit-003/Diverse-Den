import 'package:flutter/material.dart';
import 'package:sample_project/database_service.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:sample_project/screens/signup_screen.dart';
import 'package:sample_project/session_manager.dart';
import 'package:sample_project/home_screens/super_admin_home.dart';
import 'package:sample_project/home_screens/branch_owner_home.dart';
import 'package:sample_project/home_screens/customer_home.dart';
import 'package:sample_project/constants.dart';
import 'package:sample_project/widgets/text_field_widget.dart';
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String? message;

  @override
  void initState() {
    super.initState();
    checkSession();
  }

  void checkSession() async {
    var session = await SessionManager.getUserSession();
    if (session.isNotEmpty) {
      navigateToHome(session['role']!);
    }
  }

  void loginUser() async {
    String email = emailController.text.toLowerCase().trim();
    String password = passwordController.text.trim();

    // Ensure fields are filled
    if (email.isEmpty || password.isEmpty) {
      setState(() {
        message = "Please fill in all fields!";
      });
      return;
    }

    // Database authentication
    var user = await DatabaseService.getUserByEmail(email);
    if (user != null && BCrypt.checkpw(password, user['password'])) {
      await SessionManager.saveUserSession(email, user['role']);
      navigateToHome(user['role']);
    } else {
      setState(() {
        message = "Invalid email or password!";
      });
    }
  }

  void navigateToHome(String role) {
    Widget homePage;
    if (role == "Admin") {
      homePage = SuperAdminHome();
    } else if (role == "Branch Owner") {
      homePage = BranchOwnerHome();
    } else {
      homePage = CustomerHome();
    }
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => homePage));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Diverse Den App',style: TextStyle(color: Colors.white),),backgroundColor: buttonColor,centerTitle: true,),
      backgroundColor: fieldBackgroundColor,
      bottomNavigationBar: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Don't have an account?"),
          TextButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (ctx) => const SignUpScreen()),
              );
            },
            child: const Text("Sign Up", style: TextStyle(color: textColor)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container( 
          alignment: Alignment.center,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(logo, height: 100, width: 100),
              const SizedBox(height: 10),
              const Text("Welcome to Diverse Den",
                  style: TextStyle(
                      color: textColor, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),
              const Text("Login",
                  style: TextStyle(
                      color: textColor, fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 20),
              TextFieldWidget(
                  icon: Icons.email,
                  label: const Text("Enter Email"),
                  obscure: false,
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 10),
              TextFieldWidget(
                  icon: Icons.lock,
                  label: const Text("Enter Password"),
                  obscure: true,
                  controller: passwordController),
              const SizedBox(height: 15),
              ElevatedButton(
                style: const ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(buttonColor),
                ),
                onPressed: loginUser,
                child: const Text("Login", style: TextStyle(color: Colors.white)),
              ),
              if (message != null) const SizedBox(height: 10),
              if (message != null)
                Text(message!, style: const TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ),
    );
  }
}
