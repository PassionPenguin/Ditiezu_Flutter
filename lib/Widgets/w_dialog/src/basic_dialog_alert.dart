import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'base_dialog.dart';
import 'base_dialog_data.dart';

class BasicDialogAlertData extends BaseDialogData {
  BasicDialogAlertData({
    Widget title,
    Widget content,
    List<Widget> actions,
  }) : super(
          title: title,
          content: content,
          actions: actions,
        );
}

class BasicDialogAlert extends BaseDialog<AlertDialog, CupertinoAlertDialog> {
  BasicDialogAlert({
    this.title,
    this.content,
    this.actions,
  });

  final Widget title;
  final Widget content;
  final List<Widget> actions;

  static BaseDialogBuilder<BasicDialogAlertData> android;
  static BaseDialogBuilder<BasicDialogAlertData> ios;

  @override
  AlertDialog buildAndroidWidget(BuildContext context) {
    BasicDialogAlertData data;

    if (android != null) {
      data = android(context);
    }

    return AlertDialog(
      title: data?.title ?? title,
      content: data?.content ?? content,
      actions: data?.actions ?? actions,
    );
  }

  @override
  CupertinoAlertDialog buildiOSWidget(BuildContext context) {
    BasicDialogAlertData data;

    if (ios != null) {
      data = ios(context);
    }

    return CupertinoAlertDialog(
      title: data?.title ?? title,
      content: data?.content ?? content,
      actions: data?.actions ?? actions,
    );
  }
}
