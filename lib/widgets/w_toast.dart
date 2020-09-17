import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart' hide Toast;

class Toast {
  Toast(BuildContext ctx, String message, {MaterialColor accentColor = Colors.lightGreen, IconData icon = CupertinoIcons.check_mark}) {
    var ft = FToast();
    ft.init(ctx);
    ft.showToast(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
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
              Text(message, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        toastDuration: Duration(seconds: 2),
        positionedToastBuilder: (context, child) {
          return Positioned(
            child: child,
            top: 48.0,
            left: 0,
            right: 0,
          );
        });
  }
}
