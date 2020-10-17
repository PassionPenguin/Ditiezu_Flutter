import 'package:flutter/widgets.dart';

abstract class BaseActionData {
  BaseActionData({
    this.onPressed,
    this.title,
  });

  final VoidCallback onPressed;
  final Widget title;
}
