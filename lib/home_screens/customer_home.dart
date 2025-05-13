import 'package:flutter/material.dart';
import 'package:sample_project/screens/customer_profile_screen.dart';
import 'package:sample_project/screens/for_you_page.dart';
import 'package:sample_project/screens/store_page.dart';
import 'package:sample_project/session_manager.dart';
import 'package:sample_project/screens/login_screen.dart';
import 'package:sample_project/screens/following_page.dart';
import 'package:sample_project/constants.dart';
import 'package:sample_project/screens/search_screen.dart';
// import 'package:sample_project/test_3d_model.dart'; 

class CustomerHome extends StatefulWidget {
  const CustomerHome({super.key});

  @override
  State<CustomerHome> createState() => _CustomerHomeState();
}

class _CustomerHomeState extends State<CustomerHome> {
  int _selectedIndex = 0;
  bool isForYouSelected = true; 

  void logout() async {
    await SessionManager.clearSession();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      Column(
        children: [
          SizedBox(height: MediaQuery.of(context).padding.top), 

          Container(
            color: buttonColor,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isForYouSelected = false;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      "Following",
                      style: TextStyle(
                        color: isForYouSelected ? Colors.white54 : Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                horizontalSpace(20), 
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isForYouSelected = true;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      "For You",
                      style: TextStyle(
                        color: isForYouSelected ? Colors.white : Colors.white54,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: isForYouSelected ? const ForYouPage() : const FollowingPage(),
          ),
        ],
      ),
      // Container(color: fieldBackgroundColor,child: const Center(child: Text('Search Business/Product', style: TextStyle(fontSize: 18,color: textColor)))),
      const SearchScreen(),
      const StorePage(),
      Container(color: fieldBackgroundColor,child: const Center(child: Text('Notifications', style: TextStyle(fontSize: 18,color: textColor)))),
      const CustomerProfileScreen()
    ];

    return Scaffold(
      backgroundColor: Colors.black, 
      body: pages[_selectedIndex],

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          border: const Border(
            top: BorderSide(color: Colors.grey, width: 0.3),
          ),
        ),
        child: BottomNavigationBar(
          backgroundColor: buttonColor,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: textColor, 
          unselectedItemColor: Colors.white,
          showUnselectedLabels: true,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
            BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Store'),
            BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notifications'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          ],
        ),
      ),
    );
  }
}
