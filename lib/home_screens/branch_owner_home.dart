import 'package:flutter/material.dart'; 
import 'package:sample_project/session_manager.dart';
import 'package:sample_project/screens/login_screen.dart';
import 'package:sample_project/screens/upload_3d_model_screen.dart';

class BranchOwnerHome extends StatefulWidget {
  const BranchOwnerHome({super.key});

  @override
  State<BranchOwnerHome> createState() => _BranchOwnerHomeState();
}

class _BranchOwnerHomeState extends State<BranchOwnerHome> {
  int _selectedIndex = 0;

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
      Center(child: Text('3D Models Feed')),
      Center(child: Text('Search Business/Product')),
      Upload3DModelScreen(), // Navigates to the 3D model upload screen
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
      appBar: AppBar(title: Text('Branch Owner Dashboard')),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.upload), label: 'Upload'),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green,
        onTap: _onItemTapped,
      ),
    );
  }
}
