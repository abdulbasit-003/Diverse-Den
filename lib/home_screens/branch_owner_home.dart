import 'package:flutter/material.dart';
import 'package:sample_project/screens/for_you_page.dart';
import 'package:sample_project/screens/search_screen.dart';
import 'package:sample_project/session_manager.dart';
import 'package:sample_project/screens/login_screen.dart';
import 'package:sample_project/screens/upload_3d_model_screen.dart';
import 'package:sample_project/constants.dart';
import 'package:sample_project/screens/branch_owner_profile.dart';
// import 'package:sample_project/test_3d_model.dart';

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
            child: Center(
              child: Text(
                "3D Models Feed",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const Expanded(child: ForYouPage()),
        ],
      ),
      const SearchScreen(),
      const Upload3DModelScreen(),
      Container(color: fieldBackgroundColor,child: const Center(child: Text('Notifications', style: TextStyle(fontSize: 18,color: textColor)))),
      const BranchOwnerProfileScreen(),
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
            BottomNavigationBarItem(icon: Icon(Icons.upload), label: 'Upload'),
            BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notifications'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          ],
        ),
      ),
    );
  }
}
