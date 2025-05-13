import 'package:flutter/material.dart';
import 'package:sample_project/widgets/product_card.dart';
import '../models/business.dart';
import '../constants.dart';
import '../database_service.dart';
import '../session_manager.dart';

class BusinessProfileView extends StatefulWidget {
  final Business business;

  const BusinessProfileView({super.key, required this.business});

  @override
  State<BusinessProfileView> createState() => _BusinessProfileViewState();
}

class _BusinessProfileViewState extends State<BusinessProfileView> {
  List<Map<String, dynamic>> models = [];
  bool isLoading = true;
  bool isFollowing = false;
  String? currentUserEmail;
  bool isAdmin = false;
  var currentUser;

  @override
  void initState() {
    super.initState();
    _fetchModels();
    _initialize();
  }

  Future<void> _initialize() async {
    final session = await SessionManager.getUserSession();
    currentUserEmail = session['email'];
    final user = await DatabaseService.getUserByEmail(session['email']!);
    if (user!['role'] == 'Admin') {
      isAdmin = true;
    }
    final following = await DatabaseService.isFollowingBusiness(
      customerEmail: currentUserEmail!,
      businessId: widget.business.id,
    );

    setState(() {
      isFollowing = following;
    });

    await _fetchModels();
  }

  Future<void> _fetchModels() async {
    final allModels = await DatabaseService.getProductsWith3DModels();
    final filteredModels =
        allModels
            .where(
              (model) =>
                  model['business'].toString() == widget.business.id.toString(),
            )
            .toList();

    setState(() {
      models = filteredModels;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final business = widget.business;

    return Scaffold(
      backgroundColor: fieldBackgroundColor,
      appBar: AppBar(
        backgroundColor: buttonColor,
        title: const Text(
          'Business Profile',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body:
          isLoading
              ? const Center(
                child: CircularProgressIndicator(color: buttonColor),
              )
              : RefreshIndicator(
                onRefresh: _initialize,
                color: buttonColor,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      verticalSpace(30),
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
                      verticalSpace(10),
                      Text(
                        business.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      verticalSpace(5),
                      Text(
                        business.description,
                        maxLines: 3,
                        style: const TextStyle(
                          fontSize: 16,
                          color: textColor,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      verticalSpace(20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildStatColumn(
                            'Followers',
                            business.followers.toString(),
                          ),
                          _buildStatColumn(
                            'Following',
                            business.following.toString(),
                          ),
                          _buildStatColumn('Likes', business.likes.toString()),
                        ],
                      ),
                      verticalSpace(10),
                      (isAdmin)
                          ? verticalSpace(1)
                          : Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: buttonColor,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              onPressed: () async {
                                if (currentUserEmail == null) return;

                                await DatabaseService.toggleFollowBusiness(
                                  customerEmail: currentUserEmail!,
                                  businessId: widget.business.id,
                                );

                                final updatedStatus =
                                    await DatabaseService.isFollowingBusiness(
                                      customerEmail: currentUserEmail!,
                                      businessId: widget.business.id,
                                    );

                                setState(() {
                                  isFollowing = updatedStatus;
                                });
                              },
                              child: Text(
                                isFollowing ? 'Unfollow' : 'Follow',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                      verticalSpace(20),
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
                            itemCount: models.length,
                            itemBuilder: (context, index) {
                              final product = models[index];
                              return ProductCard(product: product);
                            },
                          ),
                      verticalSpace(30),
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
}
