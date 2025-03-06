import 'package:flutter/material.dart';

class FollowingPage extends StatelessWidget {
  const FollowingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Matches TikTok-style dark background
      body: Center(
        child: Text(
          "Following Page (Coming Soon)",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
    );
  }
}
