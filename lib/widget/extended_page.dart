import 'dart:io';

import 'package:flutter/material.dart';

class ExtendedPage extends StatelessWidget {
  const ExtendedPage({Key? key, required this.child}) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
      // var buttons = [], navigator = Navigator.of(context);
      var toolbar = Padding(
          padding: const EdgeInsets.only(left: 64),
          child: Row(children: [
            NavButton(const Icon(Icons.chevron_left, color: Colors.black), () {
              Navigator.of(context).maybePop();
            }),
            const Text("Ditiezu", textAlign: TextAlign.center)
          ]));
      return Scaffold(
          body: Container(
              alignment: Alignment.topCenter,
              child: Column(children: [toolbar, Expanded(child: child)])));
    }
    return Scaffold(body: Align(alignment: Alignment.topCenter, child: child));
  }

  Widget NavButton(Widget child, VoidCallback callback) {
    var button = ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(24.0)),
      child: Material(
        color: Colors.white, // Button color
        child: InkWell(
            splashColor: Colors.black, // Splash color
            onTap: callback,
            child: SizedBox(width: 24, height: 24, child: child)),
      ),
    );
    return Padding(padding: const EdgeInsets.all(4), child: button);
  }
}
