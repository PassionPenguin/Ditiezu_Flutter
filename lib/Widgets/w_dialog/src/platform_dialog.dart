import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Future<T> showPlatformDialog<T>({
  @required BuildContext context,
  @required WidgetBuilder builder,
  androidBarrierDismissible = false,
}) {
  final platform = Theme.of(context).platform;

  switch (platform) {
    case TargetPlatform.android:
    case TargetPlatform.fuchsia:
    case TargetPlatform.windows:
      return showDialog<T>(
        context: context,
        builder: builder,
        barrierDismissible: androidBarrierDismissible,
      );
    case TargetPlatform.iOS:
    case TargetPlatform.macOS:
    case TargetPlatform.linux:
      return showCupertinoDialog<T>(
        context: context,
        builder: builder,
      );
    default:
      throw UnsupportedError("Platform is not supported by this plugin.");
  }
}
