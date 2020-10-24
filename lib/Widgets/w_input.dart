import 'package:flutter/material.dart';

class TextInput extends StatelessWidget {
  TextInput(this.controller, this.keyboardType, {this.prefix, this.placeholder = "", this.obscureText = false});

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(contentPadding: EdgeInsets.all(12), labelText: placeholder, border: OutlineInputBorder(borderRadius: BorderRadius.circular(3.0), borderSide: BorderSide(width: 0.8))),
      obscureText: obscureText,
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(fontSize: 14)
    );
  }

  final TextEditingController controller;

  final TextInputType keyboardType;
  final Widget prefix;
  final String placeholder;
  final bool obscureText;
}
