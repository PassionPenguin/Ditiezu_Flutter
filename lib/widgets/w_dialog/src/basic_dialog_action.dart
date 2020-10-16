import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'base_action_data.dart';
import 'base_dialog.dart';

class BasicDialogActionData extends BaseActionData {
  BasicDialogActionData({
    VoidCallback onPressed,
    Widget title,
  }) : super(
          onPressed: onPressed,
          title: title,
        );
}

class BasicDialogAction extends BaseDialog<FlatButton, CupertinoDialogAction> {
  BasicDialogAction({
    this.onPressed,
    this.title,
  });

  final VoidCallback onPressed;
  final Widget title;

  @override
  FlatButton buildAndroidWidget(BuildContext context) {
    return FlatButton(
      onPressed: onPressed,
      child: title ?? Container(),
    );
  }

  @override
  CupertinoDialogAction buildiOSWidget(BuildContext context) {
    return CupertinoDialogAction(
      onPressed: onPressed,
      child: title ?? Container(),
    );
  }
}
