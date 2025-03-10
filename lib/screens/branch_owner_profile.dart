import 'package:flutter/material.dart';
import 'package:sample_project/database_service.dart';
import 'package:sample_project/session_manager.dart';
import 'package:sample_project/constants.dart';
import 'package:sample_project/screens/login_screen.dart';

class BranchOwnerProfileScreen extends StatefulWidget {
  const BranchOwnerProfileScreen({super.key});

  @override
  State<BranchOwnerProfileScreen> createState() => _BranchOwnerProfileScreenState();
}

class _BranchOwnerProfileScreenState extends State<BranchOwnerProfileScreen> {
  Map<String, dynamic>? businessData;
  bool isLoading = true;
  bool isViewingOtherProfile = false; // Assume this determines profile ownership

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
      businessData = await DatabaseService.getBusiness(user!['business']);
      setState(() {
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
        backgroundColor: textColor,
        elevation: 0,
        title: Text('Branch Owner Profile',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: logout,
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: buttonColor))
          : businessData == null
              ? Center(child: Text('Business data not found', style: TextStyle(color: textColor)))
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 30),
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: textColor, width: 3),
                        ),
                        child: const CircleAvatar(
                          radius: 50,
                          backgroundImage: AssetImage(logo),
                          backgroundColor: fieldBackgroundColor,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        businessData!['name'],
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        businessData!['description'],
                        style: TextStyle(fontSize: 16, color: textColor),
                      ),
                      const SizedBox(height: 20),

                      // Follow & Update Profile Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (isViewingOtherProfile)
                            ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(backgroundColor: buttonColor),
                              child: const Text('Follow', style: TextStyle(color: Colors.white)),
                            ),
                          const SizedBox(width: 10),
                          if(isViewingOtherProfile == false)
                            ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(backgroundColor: buttonColor),
                              child: const Text('Update Profile', style: TextStyle(color: Colors.white)),
                            ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Followers, Following, Likes
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildStatColumn('Followers', '1.2K'),
                          _buildStatColumn('Following', '300'),
                          _buildStatColumn('Likes', '5.6K'),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Product Stripe Section
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        color: textColor,
                        child: const Center(
                          child: Text('Products',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                      ),
                      verticalSpace(5),
                      // Example Products List
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: 4,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 1,
                        ),
                        itemBuilder: (context, index) {
                          return Container(
                            decoration: BoxDecoration(
                              color: fieldBackgroundColor,
                            ),
                            child: Center(
                              child: Text(
                                'Model ${index + 1}',
                                style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 14, color: textColor),
          ),
        ],
      ),
    );
  }
}
