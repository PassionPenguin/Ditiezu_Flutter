import 'package:Ditiezu/widgets/w_toast/w_toast.dart';
import 'package:flutter/material.dart';

class LoadingWidget {
  var ft = new FToast();
  BuildContext ctx;

  LoadingWidget(this.ctx) {
    ft.init(ctx);
    ft.showToast(
        child: ClipRRect(borderRadius: BorderRadius.circular(18), child: SizedBox(width: 36, height: 36, child: CircularProgressIndicator(strokeWidth: 8.0))));
  }

  void onCancel() {
    try {
      ft.remove();
    } catch (e) {}
  }
}
