import 'package:flutter/material.dart';

class NavigateService {
  final GlobalKey<NavigatorState> key = GlobalKey(debugLabel: 'navigate_key');

  NavigatorState get navigator => key.currentState;

  get pushNamed => navigator.pushNamed;
  get push => navigator.push;
  get pushReplacementNamed => navigator.pushReplacementNamed;
  get pushReplacement => navigator.pushReplacement;
  get popAndPushNamed => navigator.popAndPushNamed;
}
