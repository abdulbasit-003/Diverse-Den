import 'package:flutter/material.dart';
import 'package:sample_project/session_manager.dart';
import 'package:sample_project/screens/login_screen.dart';

class SuperAdminHome extends StatefulWidget {
  const SuperAdminHome({super.key});
  @override
  State<SuperAdminHome> createState() => _SuperAdminHomeState();
}

class _SuperAdminHomeState extends State<SuperAdminHome> {
  int _selectedIndex = 0;

  void logout() async {
    await SessionManager.clearSession();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    ); // Navigates back to login
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      Center(child: Text('3D Models Feed')),
      Center(child: Text('Search Business/Product')),
      Center(child: Text('Upload 3D Model')),
      Center(child: Text('Notifications')),
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Profile'),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: logout, // Calls logout properly
            child: Text('Logout'),
          ),
        ],
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text('Super Admin Dashboard')),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.upload), label: 'Upload'),
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
