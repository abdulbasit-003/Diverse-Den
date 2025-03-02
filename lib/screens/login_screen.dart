import 'package:flutter/material.dart';
import 'package:diverseden/database_service.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:diverseden/screens/signup_screen.dart';
import 'package:diverseden/session_manager.dart';
import 'package:diverseden/home_screens.dart/super_admin_home.dart';
import 'package:diverseden/home_screens.dart/branch_owner_home.dart';
import 'package:diverseden/home_screens.dart/customer_home.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

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
    var email = emailController.text;
    var password = passwordController.text;

    var user = await DatabaseService.getUserByEmail(email);
    if (user != null && BCrypt.checkpw(password, user['password'])) {
      await SessionManager.saveUserSession(email, user['role']);
      navigateToHome(user['role']);
    } else {
      print("Invalid credentials");
    }
  }

  void navigateToHome(String role) {
    Widget homePage;
    if (role == "Super Admin") {
      homePage = SuperAdminHome();
    } else if (role == "Branch Owner") {
      homePage = BranchOwnerHome();
    } else {
      homePage = CustomerHome();
    }
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => homePage));
  }

  void logoutUser() async {
    await SessionManager.clearSession();
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => LoginPage()));
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: Text("Login")),
    body: Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            controller: emailController,
            decoration: InputDecoration(labelText: "Email"),
          ),
          TextField(
            controller: passwordController,
            decoration: InputDecoration(labelText: "Password"),
            obscureText: true,
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: loginUser,
            child: Text("Login"),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SignupPage()),
              );
            },
            child: Text("Don't have an account? Sign Up"),
          ),
        ],
      ),
    ),
  );
}
}

