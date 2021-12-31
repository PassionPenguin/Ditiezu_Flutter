import 'package:flutter/material.dart';

Color setColor(
    Set<MaterialState> states, Color interactiveColor, Color defaultColor) {
  const Set<MaterialState> interactiveStates = <MaterialState>{
    MaterialState.pressed,
    MaterialState.hovered,
    MaterialState.focused,
  };
  if (states.any(interactiveStates.contains)) {
    return interactiveColor;
  }
  return defaultColor;
}

var baseThemeData = ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.grey,
    textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
            textStyle:
                MaterialStateProperty.all(const TextStyle(color: Colors.black)),
            splashFactory: InkRipple.splashFactory,
            overlayColor: MaterialStateProperty.resolveWith((states) {
              return setColor(states, Colors.black12, Colors.transparent);
            }))));
