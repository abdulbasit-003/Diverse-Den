import 'package:flutter/material.dart';
import 'package:sample_project/database_service.dart';
import 'package:sample_project/session_manager.dart';
import 'package:sample_project/constants.dart';
import 'package:sample_project/screens/login_screen.dart';

class SuperAdminProfileScreen extends StatefulWidget {
  const SuperAdminProfileScreen({super.key});

  @override
  State<SuperAdminProfileScreen> createState() =>
      _SuperAdminProfileScreenState();
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
      var user = await DatabaseService.getUserByEmail(email);
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
      backgroundColor: fieldBackgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: buttonColor,
        elevation: 0,
        title: const Text(
          'Admin Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      backgroundColor: Colors.white,
                      title: const Text('Confirm Logout?'),
                      content: const Text('Are you sure you want to logout?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(color: textColor),
                          ),
                        ),
                        TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: buttonColor,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            logout();
                          },
                          child: const Text(
                            'Logout',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
              );
            },
          ),
        ],
      ),
      body:
          isLoading
              ? const Center(
                child: CircularProgressIndicator(color: buttonColor),
              )
              : userData == null
              ? const Center(
                child: Text(
                  'User data not found',
                  style: TextStyle(color: textColor),
                ),
              )
              : SingleChildScrollView(
                child: Center(
                  child: Column(
                    children: [
                      const SizedBox(height: 30),
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: textColor, width: 3),
                        ),
                        child:
                            userData!['profilePicture'] != null &&
                                    userData!['profilePicture'].isNotEmpty
                                ? CircleAvatar(
                                  radius: 50,
                                  backgroundColor: fieldBackgroundColor,
                                  backgroundImage: NetworkImage(
                                    userData!['profilePicture'],
                                  ),
                                )
                                : CircleAvatar(
                                  radius: 50,
                                  backgroundColor: buttonColor,
                                  child: Icon(
                                    Icons.person,
                                    size: 50,
                                    color: Colors.grey,
                                  ),
                                ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "${userData!['firstname']} ${userData!['lastname']}",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        userData!['email'],
                        style: const TextStyle(fontSize: 16, color: textColor),
                      ),
                      const SizedBox(height: 30),
                      // Container(
                      //   width: double.infinity,
                      //   padding: const EdgeInsets.all(10),
                      //   color: buttonColor,
                      //   child: const Center(
                      //     child: Text('Products',
                      //         style: TextStyle(
                      //             fontSize: 18,
                      //             fontWeight: FontWeight.bold,
                      //             color: Colors.white)),
                      //   ),
                      // ),
                      // const SizedBox(height: 20),
                      // const Padding(
                      //   padding: EdgeInsets.symmetric(horizontal: 20),
                      //   child: Text(
                      //     "Review Models",
                      //     textAlign: TextAlign.center,
                      //     style: TextStyle(color: textColor, fontSize: 16),
                      //   ),
                      // ),
                      // const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
    );
  }
}
