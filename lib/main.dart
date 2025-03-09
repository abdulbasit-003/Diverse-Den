import 'package:flutter/material.dart';
import 'package:sample_project/screens/login_screen.dart';
import 'package:sample_project/database_service.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  try {
    await DatabaseService.connect(); 
    print('Connected to Database!'); 
  } catch (e) {
    print("Error initializing database connection: $e");
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
      theme: ThemeData(primarySwatch: Colors.brown),
      home: LoginPage(), 
    );
  }
}
