import 'package:flutter/widgets.dart';

abstract class BaseDialogData {
  BaseDialogData({
    this.title,
    this.content,
    this.actions,
  });

  final Widget content;
  final Widget title;
  final List<Widget> actions;
}
