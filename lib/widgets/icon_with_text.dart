import 'package:flutter/material.dart';
import 'package:sample_project/constants.dart';

Widget iconWithText(
  IconData icon,
  String label,
  VoidCallback onPressed, {
  Color iconColor = iconColor,
}) {
  return Column(
    children: [
      GestureDetector(
        onTap: onPressed,
        child: Icon(icon, color: iconColor, size: 32),
      ),
      if (label.isNotEmpty)
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            label,
            style: const TextStyle(color: textColor, fontSize: 12),
          ),
        ),
    ],
  );
}
