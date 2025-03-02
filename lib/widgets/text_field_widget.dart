import 'package:diverseden/constants.dart';
import 'package:flutter/material.dart';

class TextFieldWidget extends StatelessWidget {
  final icon;
  final label;
  final obscure;
  final controller;
  final keyboardType;
  const TextFieldWidget(
      {super.key,
      required this.icon,
      this.keyboardType,
      required this.label,
      required this.obscure,
      required this.controller});
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextFormField(
        keyboardType: keyboardType,
        controller: controller,
        decoration: InputDecoration(
          filled: true,
          fillColor: fieldBackgroundColor,
          icon: Icon(icon),
          label: label,
          iconColor: iconColor,
          border: const OutlineInputBorder(),
        ),
        obscureText: obscure,
      ),
    );
  }
}
