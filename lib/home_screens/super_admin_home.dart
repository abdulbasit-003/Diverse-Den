// import 'package:sample_project/screens/for_you_page.dart';
import 'package:flutter/material.dart';
import 'package:sample_project/session_manager.dart';
import 'package:sample_project/screens/login_screen.dart';
import 'package:sample_project/test_3d_model.dart';
import 'package:sample_project/constants.dart';

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
            child: Center(
              child: Text(
                "For You",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const Expanded(child: TestForYouPage()),
        ],
      ),
      const Center(child: Text('Search Business/Product', style: TextStyle(fontSize: 18,color: Colors.white))),
      const Center(child: Text('View Reports', style: TextStyle(fontSize: 18,color: Colors.white))),
      const Center(child: Text('Notifications', style: TextStyle(fontSize: 18,color: Colors.white))),
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Profile', style: TextStyle(fontSize: 18, color: Colors.white)),
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
            BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Reports'),
            BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notifications'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          ],
        ),
      ),
    );
  }
}
