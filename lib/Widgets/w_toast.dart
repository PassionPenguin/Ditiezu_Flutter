import 'package:Ditiezu/widgets/w_toast/w_toast.dart';
import 'package:flutter/material.dart';

class Toast {
  var ft = new FToast();

  Toast(BuildContext ctx, String message, {MaterialColor accentColor = Colors.lightGreen, IconData icon = Icons.check}) {
    print(message);
    ft.init(ctx);
    ft.showToast(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24.0),
            color: accentColor[400],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white),
              SizedBox(
                width: 12.0,
              ),
              Text(message, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          ),
        ),
        // toastDuration: Duration(seconds: 2),
        positionedToastBuilder: (context, child) {
          return Positioned(
            child: child,
            top: 48.0,
            left: 0,
            right: 0,
          );
        });
    Future.delayed(Duration(seconds: 2), () {
      ft.remove();
    });
  }

  void onCancel() {
    ft.remove();
  }
}
