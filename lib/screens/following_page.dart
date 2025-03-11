import 'package:flutter/material.dart';
import 'package:sample_project/constants.dart';

class FollowingPage extends StatelessWidget {
  const FollowingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fieldBackgroundColor, 
      body: Center(
        child: Text(
          "Following Page (Coming Soon)",
          style: TextStyle(color: buttonColor, fontSize: 18),
        ),
      ),
    );
  }
}
