import 'package:flutter/material.dart';
import 'package:sample_project/session_manager.dart';
import '../models/product.dart';
import '../models/business.dart';
import '../constants.dart';
import '../database_service.dart';
import '../screens/product_details_page.dart';
import '../screens/business_profile_view.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<Product> productResults = [];
  List<Business> businessResults = [];
  bool isLoading = false;
  String searchQuery = '';
  var currentUser;

  @override
  void initState() {
    super.initState();
    loadSession();
  }

  Future<void> loadSession() async {
    final session = await SessionManager.getUserSession();
    final user = await DatabaseService.getUserByEmail(session['email']!);
    setState(() {
      currentUser = user;
    });
  }

  void performSearch(String query) async {
    setState(() {
      isLoading = true;
      searchQuery = query;
    });

    final products = await DatabaseService.searchProducts(query);
    final businessMaps = await DatabaseService.searchBusinesses(query);
    List<Business> businesses = businessMaps.map((b) => Business.fromJson(b)).toList();

    if (currentUser != null) {
      businesses = businesses.where((b) => b.id != currentUser['business']).toList();
    }

    setState(() {
      if (query.isEmpty) {
        productResults = [];
        businessResults = [];
        return;
      }
      productResults = products;
      businessResults = businesses;
      isLoading = false;
    });
  }


  Widget _buildProductCard(Product product) {
    return Card(
      color: Colors.white,
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            product.imageUrls.isNotEmpty ? product.imageUrls[0] : '',
            width: 50,
            height: 50,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const SizedBox(
                width: 50,
                height: 50,
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return const SizedBox(
                width: 50,
                height: 50,
                child: Center(
                  child: Icon(Icons.broken_image, size: 30, color: Colors.grey),
                ),
              );
            },
          ),
        ),
        title: Text(product.title),
        subtitle: Text("Rs ${product.price}"),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailPage(product: product),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBusinessCard(Business business) {
    return Card(
      color: Colors.white,
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: const CircleAvatar(backgroundImage: AssetImage(logo)),
        title: Text(business.name),
        subtitle: Text(business.description),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BusinessProfileView(business: business),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fieldBackgroundColor,
      appBar: AppBar(
        backgroundColor: buttonColor,
        title: const Text('Search', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              onChanged: (value) {
                if (value.trim().isNotEmpty) {
                  performSearch(value.trim());
                }
              },
              decoration: InputDecoration(
                hintText: 'Search products or businesses...',
                prefixIcon: const Icon(Icons.search, color: iconColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (isLoading) const CircularProgressIndicator(color: buttonColor),
            if (!isLoading && searchQuery.isNotEmpty)
              Expanded(
                child: ListView(
                  children: [
                    if (productResults.isNotEmpty) ...[
                      const Text(
                        'Products',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...productResults.map(_buildProductCard).toList(),
                    ],
                    if (businessResults.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Businesses',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...businessResults.map(_buildBusinessCard).toList(),
                    ],
                    if (productResults.isEmpty && businessResults.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                          'No results found.',
                          style: TextStyle(color: textColor),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
