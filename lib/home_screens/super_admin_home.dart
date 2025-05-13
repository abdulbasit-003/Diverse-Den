// import 'package:sample_project/screens/for_you_page.dart';
import 'package:flutter/material.dart';
import 'package:sample_project/screens/admin_profile_screen.dart';
import 'package:sample_project/constants.dart';
import 'package:sample_project/screens/for_you_page.dart';
import 'package:sample_project/screens/search_screen.dart';
import 'package:sample_project/screens/store_page.dart';
import 'package:sample_project/test_3d_model.dart';

class SuperAdminHome extends StatefulWidget {
  const SuperAdminHome({super.key});
  @override
  State<SuperAdminHome> createState() => _SuperAdminHomeState();
}

class _SuperAdminHomeState extends State<SuperAdminHome> {
  int _selectedIndex = 0;

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
            child: Center(
              child: Text(
                "3D Models",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          // const Expanded(child: TestForYouPage()),
          const Expanded(child: ForYouPage()),
        ],
      ),
      const SearchScreen(),
      const StorePage(),
      Container(color: fieldBackgroundColor,child: const Center(child: Text('Notifications', style: TextStyle(fontSize: 18,color: textColor)))),
      const SuperAdminProfileScreen(),
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
