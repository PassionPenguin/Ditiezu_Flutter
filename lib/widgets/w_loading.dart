import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class LoadingWidget {
  var ft = FToast();
  ToastStateFul tsf;

  LoadingWidget(BuildContext ctx) {
    ft.init(ctx);
    tsf = ft.showToast(
        child: ClipRRect(borderRadius: BorderRadius.circular(18), child: SizedBox(width: 36, height: 36, child: CircularProgressIndicator(strokeWidth: 8.0))), toastDuration: Duration(days: 1));
  }

  LoadingWidget onCancel() {
    ft.removeCustomToast();
    tsf.hideIt();
    return this;
  }
}
