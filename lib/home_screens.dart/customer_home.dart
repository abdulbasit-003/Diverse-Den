import 'package:diverseden/test_3d_model.dart';
import 'package:flutter/material.dart';
import 'package:diverseden/session_manager.dart';
import 'package:diverseden/screens/login_screen.dart';
import 'package:diverseden/screens/for_you_page.dart';
import 'package:diverseden/screens/following_page.dart'; // Import Following page

class CustomerHome extends StatefulWidget {
  const CustomerHome({super.key});

  @override
  State<CustomerHome> createState() => _CustomerHomeState();
}

class _CustomerHomeState extends State<CustomerHome> {
  int _selectedIndex = 0;
  bool isForYouSelected = true; // Tracks which tab (Following/For You) is active

  void logout() async {
    await SessionManager.clearSession();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
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
          Container(
            color: Colors.black, // Tab bar background color
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
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
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
                SizedBox(width: 20), // Spacing between tabs
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isForYouSelected = true;
                    });
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
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
            child: isForYouSelected ? TestForYouPage() : FollowingPage(),
          ),
        ],
      ),
      Center(child: Text('Search Business/Product')),
      Center(child: Text('E-commerce Store')),
      Center(child: Text('Notifications')),
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Profile'),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: logout,
            child: Text('Logout'),
          ),
        ],
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text('Customer Dashboard')),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Store'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notifications'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}
