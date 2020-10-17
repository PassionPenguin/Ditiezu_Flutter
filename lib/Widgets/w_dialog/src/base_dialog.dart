import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

typedef T BaseDialogBuilder<T>(BuildContext context);

abstract class BaseDialog<A extends Widget, I extends Widget> extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final platform = Theme.of(context).platform;

    switch (platform) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.windows:
        return buildAndroidWidget(context);
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.linux:
        return buildiOSWidget(context);
      default:
        throw UnsupportedError("Platform is not supported by this plugin.");
    }
  }

  A buildAndroidWidget(BuildContext context);

  I buildiOSWidget(BuildContext context);
}
