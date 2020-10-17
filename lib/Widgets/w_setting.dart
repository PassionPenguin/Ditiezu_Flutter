import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'v_empty_view.dart';

class Setting extends StatelessWidget {
  final String title;
  final String description;
  final String type;
  final Function onTap;
  final Icon icon;

  Setting(this.title, this.description, this.onTap, {this.type = TYPE_CUSTOM_ICON, this.icon = const Icon(Icons.chevron_right)});

  static const String TYPE_NOTING = "NOTHING";
  static const String TYPE_CUSTOM_ICON = "CUSTOM_ICON";

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: onTap,
        child: Container(
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              children: [
                Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  if (description == null) VEmptyView(1) else Text(description, style: TextStyle(fontSize: 14, color: Colors.grey)),
                ])),
                type == TYPE_CUSTOM_ICON
                    ? icon
                    : type == TYPE_NOTING
                        ? Text("")
                        : Switch(onChanged: onTap, value: false)
              ],
            )));
  }
}
