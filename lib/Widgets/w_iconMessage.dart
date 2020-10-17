import 'package:flutter/material.dart';

import 'v_empty_view.dart';

class IconMessage extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String message;

  const IconMessage({Key key, this.icon, this.color, this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(children: [VEmptyView(12), Icon(icon, color: color, size: 48), VEmptyView(12), Text(message, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600))]);
  }
}
