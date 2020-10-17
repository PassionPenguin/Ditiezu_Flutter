import 'package:flutter/material.dart';

Widget radiusButton({Widget child, GestureTapCallback action, bool colored = true}) {
  return GestureDetector(
      child: Container(
          margin: EdgeInsets.symmetric(horizontal: 3),
          width: 30,
          height: 30,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(6.0), color: colored ? Color(0xFFEEEEEE) : Colors.transparent),
          child: Center(child: child)),
      onTap: action);
}
