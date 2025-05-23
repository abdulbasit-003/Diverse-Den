import 'package:flutter/material.dart';
import 'package:sample_project/constants.dart';

class TextFieldWidget extends StatelessWidget {
  final IconData icon;
  final Widget label;
  final bool obscure;
  final TextEditingController controller;
  final TextInputType keyboardType;

  const TextFieldWidget({
    super.key,
    required this.icon,
    required this.label,
    required this.obscure,
    required this.controller,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        enableSuggestions: true,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: iconColor),
          label: label,
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        ),
      ),
    );
  }
}
