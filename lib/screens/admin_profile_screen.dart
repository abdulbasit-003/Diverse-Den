import 'package:flutter/material.dart';
import 'package:sample_project/database_service.dart';
import 'package:sample_project/session_manager.dart';
import 'package:sample_project/constants.dart';
import 'package:sample_project/screens/login_screen.dart';

class SuperAdminProfileScreen extends StatefulWidget {
  const SuperAdminProfileScreen({super.key});

  @override
  State<SuperAdminProfileScreen> createState() => _SuperAdminProfileScreenState();
}

class _SuperAdminProfileScreenState extends State<SuperAdminProfileScreen> {
  Map<String, dynamic>? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    var session = await SessionManager.getUserSession();
    String? email = session['email'];

    if (email != null) {
      var user = await DatabaseService.getUserProfile(email);
      setState(() {
        userData = user;
        isLoading = false;
      });
    }
  }

  void logout() async {
    await SessionManager.clearSession();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('Admin Profile', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: iconColor),
            onPressed: logout,
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: buttonColor))
          : userData == null
              ? Center(child: Text('User data not found', style: TextStyle(color: textColor)))
              : SingleChildScrollView(
                  child: Center( // Centers everything
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        verticalSpace(30),
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: AssetImage(logo), // Default Profile Picture
                          backgroundColor: fieldBackgroundColor,
                        ),
                        verticalSpace(10),
                        Text(
                          "${userData!['firstname']} ${userData!['lastname']}",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor),
                        ),
                        verticalSpace(5),
                        Text(
                          userData!['email'],
                          style: TextStyle(fontSize: 16, color: textColor.withOpacity(0.7)),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}
