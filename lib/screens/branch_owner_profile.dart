import 'package:flutter/material.dart';
import 'package:sample_project/database_service.dart';
import 'package:sample_project/session_manager.dart';
import 'package:sample_project/constants.dart';
import 'package:sample_project/screens/login_screen.dart';
import 'package:sample_project/widgets/owner_product_card.dart';
// import 'package:sample_project/widgets/product_card.dart';

class BranchOwnerProfileScreen extends StatefulWidget {
  const BranchOwnerProfileScreen({super.key});

  @override
  State<BranchOwnerProfileScreen> createState() =>
      _BranchOwnerProfileScreenState();
}

class _BranchOwnerProfileScreenState extends State<BranchOwnerProfileScreen> {
  Map<String, dynamic>? businessData;
  List<Map<String, dynamic>> models = [];
  bool isLoading = true;
  bool isViewingOtherProfile = false;
  int followingCount = 0;
  var userData;

  @override
  void initState() {
    super.initState();
    _fetchUserProfileAndModels();
  }

  Future<void> _fetchUserProfileAndModels() async {
    var session = await SessionManager.getUserSession();
    String? email = session['email'];

    if (email != null) {
      var user = await DatabaseService.getUserByEmail(email);
      var business = await DatabaseService.getBusiness(user!['business']);
      var allModels = await DatabaseService.getProductsWith3DModels();

      followingCount = (user['followedBusinesses'] as List?)?.length ?? 0;

      // Filtering only models belonging to this branch owner's business
      var filteredModels =
          allModels
              .where(
                (model) =>
                    model['business'].toString() == user['business'].toString(),
              )
              .toList();

      setState(() {
        businessData = business;
        models = filteredModels;
        isLoading = false;
        userData = user;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Session ended. Please login again!')),
      );
      logout();
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
        backgroundColor: buttonColor,
        automaticallyImplyLeading: false,
        elevation: 0,
        title: const Text(
          'Branch Owner Profile',
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
                      title: const Text('Confirm Logout?'),
                      content: const Text('Are you sure you want to logout?'),
                      actions: [
                        TextButton(
                          onPressed:
                              () => Navigator.pop(context), 
                          child: const Text('Cancel',style: TextStyle(color: textColor),),
                        ),
                        TextButton(
                          style: TextButton.styleFrom(backgroundColor: buttonColor),
                          onPressed: () {
                            Navigator.pop(context); 
                            logout(); 
                          },
                          child: const Text('Logout',style: TextStyle(color: Colors.white),),
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
              ? Center(child: CircularProgressIndicator(color: buttonColor))
              : businessData == null
              ? Center(
                child: Text(
                  'Business data not found',
                  style: TextStyle(color: textColor),
                ),
              )
              : RefreshIndicator(
                onRefresh: _fetchUserProfileAndModels,
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
                        businessData!['name'],
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        businessData!['description'],
                        maxLines: 3,
                        style: TextStyle(fontSize: 16, color: textColor),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildStatColumn(
                            'Followers',
                            businessData!['followers'].toString(),
                          ),
                          _buildStatColumn(
                            'Following',
                            followingCount.toString(),
                          ),
                          _buildStatColumn(
                            'Likes',
                            businessData!['likes'].toString(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        color: buttonColor,
                        child: const Center(
                          child: Text(
                            'Products',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      verticalSpace(5),
                      models.isEmpty
                          ? Padding(
                            padding: const EdgeInsets.all(20),
                            child: Text(
                              "No 3D models uploaded yet!",
                              style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                          : models.isEmpty
                          ? Padding(
                            padding: const EdgeInsets.all(20),
                            child: Text(
                              "No 3D models uploaded yet!",
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
                            itemCount: models.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                  childAspectRatio: 0.75,
                                ),
                            itemBuilder: (context, index) {
                              final product = models[index];
                              return OwnerProductCard(product: product);
                            },
                          ),
                      const SizedBox(height: 30),
                    ],
                  ),
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
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          Text(label, style: TextStyle(fontSize: 14, color: textColor)),
        ],
      ),
    );
  }
}
