// import 'package:sample_project/screens/for_you_page.dart';
import 'package:flutter/material.dart';
import 'package:sample_project/session_manager.dart';
import 'package:sample_project/screens/login_screen.dart';
import 'package:sample_project/screens/following_page.dart';
import 'package:sample_project/constants.dart';
import 'package:sample_project/test_3d_model.dart'; 
class CustomerHome extends StatefulWidget {
  const CustomerHome({super.key});

  @override
  State<CustomerHome> createState() => _CustomerHomeState();
}

class _CustomerHomeState extends State<CustomerHome> {
  int _selectedIndex = 0;
  bool isForYouSelected = true; // Tracks the selected tab (Following/For You)

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
            color: Colors.black,
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
            child: isForYouSelected ? const TestForYouPage() : const FollowingPage(),
          ),
        ],
      ),
      const Center(child: Text('Search Business/Product', style: TextStyle(fontSize: 18,color: Colors.white))),
      const Center(child: Text('E-commerce Store', style: TextStyle(fontSize: 18,color: Colors.white))),
      const Center(child: Text('Notifications', style: TextStyle(fontSize: 18,color: Colors.white))),
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Profile', style: TextStyle(fontSize: 18,color: Colors.white)),
          verticalSpace(20), 
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: buttonColor), 
            onPressed: logout,
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
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
          backgroundColor: Colors.black,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: textColor, 
          unselectedItemColor: Colors.grey,
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
