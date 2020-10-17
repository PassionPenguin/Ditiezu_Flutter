import 'package:flutter/cupertino.dart';

class TextInput extends StatelessWidget {
  TextInput(this.controller, this.keyboardType, {this.prefix, this.placeholder = "", this.style, this.obscureText = false});

  @override
  Widget build(BuildContext context) {
    return CupertinoTextField(
        obscureText: obscureText,
        controller: controller,
        keyboardType: keyboardType,
        padding: EdgeInsets.all(12),
        prefix: prefix == null ? Row() : prefix,
        placeholder: placeholder,
        style: style == null ? TextStyle() : style);
  }

  final TextEditingController controller;

  final TextInputType keyboardType;
  final Widget prefix;
  final String placeholder;
  final TextStyle style;
  final bool obscureText;
}
//               CupertinoTextField(
//                 obscureText: true,
//                 controller: _pwdController,
//                 keyboardType: TextInputType.visiblePassword,
//                 padding: EdgeInsets.all(12),
//                 prefix: Row(children: [
//                   Padding(padding: EdgeInsets.only(left: 12)),
//                   Icon(Icons.lock, color: Colors.grey, size: 16)
//                 ]),
//                 placeholder: "Password",
//                 style: TextStyle(fontSize: 14),
//               )
