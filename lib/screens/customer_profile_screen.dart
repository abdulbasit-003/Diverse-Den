import 'package:flutter/material.dart';
import 'package:sample_project/database_service.dart';
import 'package:sample_project/session_manager.dart';
import 'package:sample_project/constants.dart';
import 'package:sample_project/screens/login_screen.dart';
import 'package:sample_project/widgets/product_card.dart';

class CustomerProfileScreen extends StatefulWidget {
  const CustomerProfileScreen({super.key});

  @override
  State<CustomerProfileScreen> createState() => _CustomerProfileScreenState();
}

class _CustomerProfileScreenState extends State<CustomerProfileScreen> {
  Map<String, dynamic>? userData;
  bool isLoading = true;
  int followingCount = 0;
  List<Map<String, dynamic>> likedProducts = [];

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
      var followedBusinessIds = user!['followedBusinesses'] ?? [];

      followingCount = followedBusinessIds.length;

      likedProducts = await DatabaseService.getLikedProductsByUser(email);

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

  Widget _buildStatColumn(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          Text(label, style: const TextStyle(fontSize: 14, color: textColor)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fieldBackgroundColor,
      appBar: AppBar(
        backgroundColor: buttonColor,
        automaticallyImplyLeading: false,
        elevation: 0,
        title: const Text(
          'Your Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: logout,
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
              : RefreshIndicator(
                onRefresh: _fetchUserProfile,
                color: buttonColor,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      const SizedBox(height: 30),
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: textColor, width: 3),
                        ),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: fieldBackgroundColor,
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
                          overflow: TextOverflow.ellipsis,
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
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildStatColumn(
                            'Following',
                            followingCount.toString(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        color: buttonColor,
                        child: const Center(
                          child: Text(
                            'Liked Products',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      verticalSpace(5),
                      likedProducts.isEmpty
                          ? Padding(
                            padding: const EdgeInsets.all(20),
                            child: Text(
                              "No liked products yet!",
                              style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                          : GridView.builder(
                            padding: const EdgeInsets.all(10),
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                  childAspectRatio: 0.75,
                                ),
                            itemCount: likedProducts.length,
                            itemBuilder: (context, index) {
                              final product = likedProducts[index];
                              return ProductCard(product: product);
                            },
                          ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
    );
  }
}
