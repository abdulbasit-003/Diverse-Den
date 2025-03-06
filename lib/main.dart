import 'package:flutter/material.dart';
import 'package:sample_project/screens/login_screen.dart';
// import 'package:diverseden/screens/signup_screen.dart';
import 'database_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await DatabaseService.connect(); 
    print('Connected to Database!'); // Ensure database is connected before the app runs
  } catch (e) {
    print("❌ Error initializing database connection: $e");
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DiverseDen App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: LoginPage(), // Start with Login Page
      // routes: {
      //   '/signup': (context) => SignupPage(), // Navigate to Signup
      // },
    );
  }
}
