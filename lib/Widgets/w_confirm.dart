import 'package:flutter/material.dart';

import 'w_dialog/w_dialog.dart';

class Confirm {
  final BuildContext context;
  final String title;
  final String content;
  final Function onPressed;

  Confirm(this.context, this.title, this.content, this.onPressed) {
    showPlatformDialog(
      context: context,
      builder: (_) => BasicDialogAlert(
        title: Text(title),
        content: Text(content),
        actions: <Widget>[
          BasicDialogAction(
            title: Text("取消"),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          BasicDialogAction(
            title: Text("确认"),
            onPressed: () {
              this.onPressed();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
